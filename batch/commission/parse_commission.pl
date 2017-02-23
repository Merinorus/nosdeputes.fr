#!/usr/bin/perl

use URI::Escape;
require "../common/common.pm";

$file = shift;
$url_source = uri_unescape($file);
if ($url_source =~ /(2\d{3})/) {
    $url_year = $1;
}
$url_source =~ s/.*html.*\/http/http/;


open FILE, $file;
@lignes = <FILE>;
close FILE;
$content = "@lignes";
$content =~ s/\n//g;
$content =~ s/(<td[^>]*>)(\s*<\/?(a|strong|p|em)[^>]*>)+/$1/gi;
$content =~ s/<\/?(a|strong|p|em)[^>]*>\s*<\/td>/<\/td>/gi;
$content =~ s/<br\/?\s?>/ /ig;
$content =~ s/[ \t]+/ /g;
$content =~ s/&(#160|nbsp);/ /ig;
$content =~ s/<\/?em>//gi;
$content =~ s/\s+/ /g;
$content =~ s/<\/(p|h[1234]|ul|div)>/<\/$1>\n/gi;
$content =~ s/(<h\d[^>]*>)\s*<b>/$1/gi;
$content =~ s/<\/b>\s*(<\/h\d[^>]*>)/$1/gi;
$content =~ s/>CS />Commission spéciale /g;
$content =~ s/ CS / Commission spéciale /g;

%fonctions = ();

$timestamp = 0;
$nb_seance = 1;
$changehour = 0;
sub print_inter {
	if ($intervention && $intervention ne '<p></p>') {
		if ($intervention =~ /(projets? de loi|textes?|propositions? de loi)( n[^<]+)/) {
			$doc = $2;
			$doc =~ s/&[^;]+;//g;
			$numeros_loi = '';
			while ($doc =~ / n\D*(\d+) ?(\(\d+\-\d+\))/g) {
				$numeros_loi .= law_numberize($1,$2).",";
			}
			if (!$numeros_loi) {
				if ($doc =~ s/\((\d+\-\d+)\)//) {
					$year = $1;
				}
				if (!$year) {
					$year = $url_year.'-'.($url_year+1);
				}
				while ($doc =~ /n\D*((\d+)(, (\d+))*( et (\d+))?)/g) {
					foreach $no (split(/(, | et )/, $1)) {
						$no =~ s/\D//g;
						next unless ($no);
						$numeros_loi .= law_numberize($no,$year).",";
					}
				}
			}
			if ($numeros_loi) {
			    chop($numeros_loi);
			    $numeros_loi =~ s/[^0-9\-\,]//g;
			}
		}
		if ($intervention =~ /amendement( n[^<]+)/) {
			$doc = $1;
			$doc =~ s/&[^;]+;//g;
                        if ($doc =~ / n\s*([COM\-\d]+)/) {
				$amendements = $1;
			}
		}
		$timestamp += 20;
		if ($date !~ /\d{4}\-\d{2}-\d{2}/) {
		    print STDERR "ERROR pas de date pour $file\n";
		    exit 1;
		}
		if (!$commission || $commission =~ /[\/<>]/) {
		    print STDERR "ERROR pas de commission pour $file\n";
		    exit 1;
		}
		print '{"commission": "'.quotize($commission).'", "contexte": "'.$context.'", "intervention": "'.quotize($intervention).'", "timestamp": "'.$timestamp.'", "date": "'.$date.'", "source": "'.$url_source.$source.'", "heure":"'.$heure.'", "intervenant": "'.name_lowerize($intervenant).'", "fonction": "'.$fonction.'", "intervenant_url": "'.$url_intervenant.'", "session":"'.$session.'"';
        	print ', "numeros_loi":"'.$numeros_loi.'"' if ($numeros_loi);
	        print ', "amendements":"'.$amendements.'"' if ($amendements);
		print "}\n";
        if ($intervenant) {
            $changehour = 0;
        }
	}
	$intervenant = '';
	$fonction = '';
	$url_intervenant = '';
	$intervention = '';
	$amendements = '';
}

sub setfonction {
	my $f = shift;
	if ($f =~ /audition de (M[^<]+)/) {
		$a = $1;
		while ($a =~ /(M[me\.]* [^\,\.]+), ([^\,\.]+)/g) {
			$fonctions{$1} = $2;
		}
	}
}

$begin = 0;
$recointer = "(M\\\.?m?e?|Amiral|Général|S\\\.E|Son |colonel)";

$interstrong = 1 if ($content =~ /<(a|strong)[^>]*>\s*($recointer[^<]*)<\/(a|strong)>/i);
foreach (split /\n/, $content) {
	last if (/END : primary/);
	s/ n<sup>[0os\s]+<\/sup>\s*/ n° /ig;
	$begin = 1 if (/name="toc[01]"/i);
#print STDERR "title: $1\n" if (/<title>([^<]*)</);
	if (/TITLE>[^<]*(Commission[^:<]*)/i) {
	    $commission = $1;
	    $commission =~ s/[\s\-]+S[é&eacut;]+nat\s*//i;
	    $commission =~ s/Commission mixte paritaire .*/Commission mixte paritaire/;
	}elsif (/fait au nom de la (commission d'enquête[^:<]*)(\s*,\s*déposé)/i) {
		$commission = $1;
	}else {
	    $commission = $1 if (/TITLE>\s*((MCI|Mission|Office|Délégation|Groupe de travail|CE |GT )[^:<]*)/i);
	    $commission =~ s/\-[\s\-]+S[é&eacut;]+nat\s*//;
            $commission =~ s/MCI /Mission commune d'information /;
	    $commission =~ s/CE /Commission d'enquête /;
	    $commission =~ s/GT /Groupe de travail /;
	}
#	print ;	print "\n";
	if ((!/\d{4}\-\d{4}/) && (/<(h[123])[^>]*>(\s*<[^>]*>)*([^<\(]+\d{4})(\W*<[^>]*>)*\W*<\/(h[123])>/i) || /(<strong)(>)\(([a-z]+ \d+ [a-zéû]+ \d{4})\)<\/strong>/) {
#print STDERR "date: $3 $url_year\n";
		@date = datize($3, $url_year);
#print STDERR length($3)."length\n";
		if (@date && (!$date || length($3) < 40)) {
#print STDERR "date:"."@date"." ($timestamp $intervention)\n";
		    print_inter() if ($date && ($intervention !~ /commission.*mixte.*paritaire/i)); # || $intervention =~ /(adopt|rejet)/);
		    $olddate = $date;
                    $date = join '-', @date;
#print STDERR "date:".$date."\n";
		    $session = sessionize(@date);
		    $numeros_loi = '';
		    $nb_seance = 1;
		    $heure = '1ère séance';
		    print_inter() if ($intervention && !$timestamp);
		    $timestamp = '0' if ($olddate ne $date);
		    next;
		}
	}
    if (!$date && !$commission && (/<[^>]*>(R\S+union d[^<]*) du (\S+ [0-9er]+ \S+ \d+)<\//)) {
        @date = datize($2, $url_year);
        $date = join '-', @date;
        $titre = $1;
        $commission = $1 if ($titre =~ /((MCI|Mission|Office|Délégation|Groupe de travail|CE |GT )[^:<]*)/i);
        $heure = '1ère séance';
    }
	if (/<h[1234][^>]*>(\s*<[^>]*>)*([^<]+)<\/h[1234]>/) {
		$titre = $2;
		next if ($titre =~ /^((com)?mission|comptes rendus |office|délégation|groupe de travail)/i && $titre !~/commission mixte paritaire/i);

		print_inter() if($timestamp);
		$context = $titre;
		setfonction($titre);
		$context =~ s/ -{1,2} / > /;
		$titre =~ s/[\s\(]+suite[\s\)]*$//i if ($context =~ s/[\s\(]+suite[\s\)]*$//i);
		$intervention = '<p>'.$titre.'</p>';
		%fonctions = ();
		$numeros_loi = '';
		$is_newcontext = 1;
	}
	$source = "#$1" if (/name="([^"]+)"/);
        next if (!$begin);

	if (/<p[^>]*>(.*)<\/p>/i) {
		$inter = $1;
		if ($inter =~ /<u>(Au cours[^<]*)<\/u>/) {
		    $aucours = $1;
		    if ($aucours =~ /quatri(è|&[^;]*;)me/) {
                if ($nb_seance >= 4) {
                    $nb_seance++ if (!$changehour);
                }else{
                    $nb_seance = 4;
                }
            }elsif ($aucours =~ /(troisi(è|&[^;]*;)me|soir(é|&[^;]*;)e)/) {
                if ($nb_seance >= 3) {
                    $nb_seance++ if (!$changehour);
                }else{
                    $nb_seance = 3;
                }
            }elsif ($aucours =~ /(seconde|apr[^s]+s( |-)*midi)/) {
                if ($nb_seance >= 2) {
                    $nb_seance++ if (!$changehour);
                }else{
                    $nb_seance = 2;
                }
		    }elsif ($aucours =~ /(premi(è|&[^;]*;)re|matin(é|&[^;]*;)e)/) {
                if ($nb_seance >= 1) {
                    $nb_seance++ if (!$changehour);
                }else{
                    $nb_seance = 1;
                }
		    }elsif (!$changehour){
                $nb_seance++;
		    }
            if ($changehour && $heure =~ /\d:\d/) {
                $tmphour = $heure;
            } else {
                $tmphour = ($nb_seance == 1 ? '1ère' : $nb_seance.'ème')." séance";
            }
		    print_inter() if (!$is_newcontext);
		    $heure = $tmphour;
		    $timestamp = '0';
            $changehour = 1;
		}elsif($inter =~ /^La [rs]&eacute;(?:union|ance) est ouverte &agrave; (\d+) ?h(eures?|) ?(\d+|) *(\.|$)/) {
			$heure = "$1:$3";
			$heure =~ s/:$/:00/;
            if (!$changehour && $nb_seance > 1) {
                $nb_seance++;
            }
            $changehour = 1;
        }

		if($is_newcontext) {
		    $is_newcontext = 0;
		    print_inter();
		}
		$inter =~ s/<a[^>]*><\/a>//ig;
		if ($inter =~ /^\s*<(u|strong|em)>(.*)<\/(u|strong|em)>\s*$/i) {
			$inter = $2;
			print_inter();
	                $inter =~ s/<[^>]+>//g;
			setfonction($inter);
			$intervention = '<p>'.$inter.'</p>';
			next;
		}

		$inter =~ s/(<\/(strong|a)[^>]*>)+([\s,]*)(<\/?(strong)[^>]*>)+/$3/ig;
		$inter =~ s/(<strong>)\s*([^<]*)<\/strong>(\s*)(<a[^>]*>)\s*<strong>/$1$4$2$3/ig;
		if (($interstrong && $inter =~ /<(a|strong)[^>]*>($recointer[^<]+)<\/(a|strong)>/i) ||
		    (!$interstrong && ($inter =~ /(>)\s*($recointer[^<]{10}[^<\.]*)/))) {
			$tmpintervenant = $2;
			$tmpintervenant =~ s/<[^>]*>//g;
			$tmpintervenant =~ s/ et /, /g if ($tmpintervenant =~ /^Mm([\.\s]|es)/);
			$tmpintervenant =~ s/^M[mles]{0,3}[\.\s]+//;
			$tmpintervenant =~ s/[\s-_\.,;"'<>«»]+$//;
			if ($tmpintervenant =~ s/^([^,]+),\s*([^,]+,\s*)*([^,]*)\W*$/$1/g) {
				$tmpfonction = $3;
				$tmpfonction = $2.$tmpfonction if ($2 !~ / M[mles\.\s]/);
				$fonctions{$tmpintervenant} = $tmpfonction;
			} elsif ($tmpintervenant =~ s/^([^,]+), ([^,]*).*/$1/g) {
				$tmpfonction = $2;
				$tmpfonction =~ s/\W+$//;
				$fonctions{$tmpintervenant} = $tmpfonction;
			}else{
			    if ($tmpintervenant =~ s/\s*l[ae].{1,6}(pr(&[^;]*;|é)sidente?)\s*/ /) {
				$tmpfonction = $1;
			    }else{
				$tmpfonction = $fonctions{$tmpintervenant};
			    }
			}
			print_inter() if ($tmpintervenant ne $intervenant);
			$intervenant = $tmpintervenant;
			$intervenant =~ s/[\s-_\.,;"'<>«»]+$//;
		        $fonction = $tmpfonction;
			$url_intervenant = $1 if ($inter =~ /href="([^"]+senfic\/[^"]+)"/i);
		}
		$inter =~ s/<[^>]+>//g;
		print_inter() if ($inter =~ /^La (com)?mission /);
		$sintervenant = $intervenant;
		$sintervenant =~ s/([\(\)\*])/\\$1/g;
		$sfonction = $fonction;
		$sfonction =~ s/([\(\)\*])/\\$1/g;
		$inter =~ s/^[^\w\&]*(M[mles]{0,3}[\.\s]+)?$sintervenant[^\w\&]*($sfonction[^\w\&]*|)//;
		$intervention .= '<p>'.$inter.'</p>' if ($inter =~ /[a-z]/i);
	}
#	print "$date $titre $source\n";
}
print_inter();
