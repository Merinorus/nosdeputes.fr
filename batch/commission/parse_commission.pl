#!/usr/bin/perl

$file = $url = shift;
#use HTML::TokeParser;
$url =~ s/^[^\/]+\///;
$url =~ s/_/\//g;
$url =~ s/commissions\/elargies/commissions_elargies/;
$source = $url;
$baseurl = $url;
$baseurl =~ s/\/[^\/]+$/\//;
$rooturl = $url;
$rooturl =~ s/^([^\/]+)\/.*$/\1/;

if ($url =~ /\/(\d+)-(\d+)\//) {
  $session = '20'.$1.'20'.$2;
} elsif ($url =~ /\/plf(\d+)\//) {
  $annee = $1-1;
  $session = $annee.$1;
}

open(FILE, $file) ;
@string = <FILE>;
$string = "@string";
close FILE;

$string =~ s/\r//g;
$string =~ s/(M\.\s*&nbsp;\s*)+/M. /g;
$string =~ s/&#278;/É/g;
$string =~ s/&#259;/ă/g;
$string =~ s/&#8211;/–/g;

$mois{'janvier'} = '01';
$mois{'février'} = '02';
$mois{'mars'} = '03';
$mois{'avril'} = '04';
$mois{'mai'} = '05';
$mois{'juin'} = '06';
$mois{'juillet'} = '07';
$mois{'août'} = '08';
$mois{'septembre'} = '09';
$mois{'octobre'} = '10';
$mois{'novembre'} = '11';
$mois{'décembre'} = '12';

$heures{'zéro'} = '00';
$heures{'une'} = '01';
$heures{'deux'} = '02';
$heures{'trois'} = '03';
$heures{'quatre'} = '04';
$heures{'cinq'} = '05';
$heures{'six'} = '06';
$heures{'sept'} = '07';
$heures{'huit'} = '08';
$heures{'neuf'} = '09';
$heures{'dix'} = '10';
$heures{'onze'} = '11';
$heures{'douze'} = '12';
$heures{'treize'} = '13';
$heures{'quatorze'} = '14';
$heures{'quinze'} = '15';
$heures{'seize'} = '16';
$heures{'dix-sept'} = '17';
$heures{'dix-huit'} = '18';
$heures{'dix-neuf'} = '19';
$heures{'vingt'} = '20';
$heures{'vingt et une'} = '21';
$heures{'vingt-et-une'} = '21';
$heures{'vingt-deux'} = '22';
$heures{'vingt-trois'} = '23';
$heures{'vingt-cinq'} = '25';
$heures{'trente'} = '30';
$heures{'trente-cinq'} = '35';
$heures{'quarante'} = '40';
$heures{'quarante-cinq'} = '45';
$heures{'cinquante'} = '50';
$heures{'cinquante-cinq'} = '55';
$heures{''} = '00';


if ($url =~ /\/plf(\d+)\//) {
  $string2 = $string;
  $string2 =~ s/\n//g;
  $string2 =~ s/\<br\/?\>//ig;
  $string2 =~ s/&nbsp;/ /ig;
  $string2 =~ s/&#8217;/'/ig;
  utf8::decode($string2);
  $string2 =~ s/\x{92}/'/g;
  utf8::encode($string2);
  $string2 =~ s/\s+/ /g;
  $string2 =~ s/^.*>commission (e|é|É)largie<.*>commission des finances.*?>commission d(e l'|(u|e la|es) )//i;
  $string2 =~ s/\(Application de l'article 120 du Règlement(.*)//i;
  $tmpdate = $1;
  $tmpdate =~ s/\<[^>]+>//ig;
  $tmpdate =~ s/^\W+//;
  if ($tmpdate =~ /^(\w+\s+)?(\d+)[erme]*\s+([^\s\d]+)\s+(\d+)/i) {
    $date = sprintf("%04d-%02d-%02d", $4, $mois{lc($3)}, $2);
  }
  $string2 =~ s/\<\/?[^>]+\>//ig;
  $string2 =~ s/^\s+//;
  $string2 =~ s/[^a-z]+$//;
  $string2 =~ s/(,| et) d.*?( Commission|$)/\2/gi;
  $string2 =~ s/ Commission d(u|e la|es) ([a-z])/ - \U\2/gi;
  $string2 =~ s/Assemblée nationale ~.*//i;
  $commission = "Commission élargie : Finances - ".ucfirst($string2);
  $commission =~ s/ - $//;
}

$string =~ s/\s*&(#160|#8232|nbsp);\s*/ /ig;
$string =~ s/\s*&#8230;/…/g;
$string =~ s/\s*&#8217;/'/g;
$string =~ s/e&#769;/é/g;
$string =~ s/e?&#768;/è/g;
$string =~ s/i?&#776;/ï/g;
$string =~ s/&amp;/&/g;
$string =~ s/(<p[^>]*>)(&#\d+;\s*|[A-Z])(<b>)/\1\3\2/ig;
$string =~ s/\s*(<\/[bi]>)\s*:\s*/ :\1 /g;
$string =~ s/\.…<\/b>/.<\/b> …/g;
$string =~ s/\s*<b>\s+<\/b>\s*/ /g;
$string =~ s/<\/b>(\s*|l')<b>/\1/g;
$string =~ s/<b>(\s*[\.,]\s*)<\/b>/\1/g;
$string =~ s/<\/[ub]>\s*,\s*<\/[ub]>/,<u><b>/g;
$string =~ s/(?:<\/?[ub]>)+\s*(\.)?\s*(?:<\/?[ub]>)+/\1<b>/g;
$string =~ s/\. ((?:[A-Z]|É)['.]?|« )<\/b>((<i>)?\s*['\w]+)/. <\/b>\1\2/g;
$string =~ s/<\/?[bu]>/|/g;
$string =~ s/<\/?i>/\//g;
$string =~ s/Mme François Dumas/Mme Françoise Dumas/gi;
$string =~ s/Mme la présente/Mme la présidente/gi;
$string =~ s/M\. Adrien Taché, rapporteur/M. Aurélien Taché, rapporteur/gi;

if ($string =~ />(?:Réunion|Séance) du (\w+\s+)?(\d+)[erme]*\s+([^\s\d]+)\s+(\d+)(?:\s+à\s+(\d+)\s*h(?:eure)?s?\s*(\d*))\.?</) {
  $tmpdate = sprintf("%04d-%02d-%02d", $4, $mois{lc($3)}, $2);
  $heure = sprintf("%02d:%02d", $5, $6 || '00');
}

if ($string =~ /réunion.*commission.*commence[^\.]+à\s+([^\.]+)\s+heures?\s*([^\.]*)\./i) {
  $heure = $heures{$1}.':'.$heures{$2};
}

#utf8::decode($string);
#
#$p = HTML::TokeParser->new(\$string);
#
#while ($t = $p->get_tag('p', 'h1', 'h5')) {
#    print "--".$p->get_text('/'.$t->[0])."\n";
#}
#
#exit;

sub comparable {
    $origstr = shift;
    $origstr = lc($origstr);
    $origstr =~ s/(à|â|ä|À|Â|Ä)/a/g;
    $origstr =~ s/(é|è|ê|ë|É|È|Ê|Ë)/e/g;
    $origstr =~ s/(î|ï|Î|Ï)/i/g;
    $origstr =~ s/(ô|ö|Ô|Ö)/o/g;
    $origstr =~ s/(ù|û|ü|Ù|Û|Ü)/u/g;
    $origstr =~ s/(ç|Ç)/c/g;
    $origstr =~ s/[^a-z]+/ /g;
    $origstr =~ s/\s+$//g;
    return $origstr;
}

$cpt = 0;
sub checkout {
    $commission =~ s/"//g;
    if ($commission =~/^\s*Mission d'information\s*$/i && $commission_meta) {
        $commission = $commission_meta;
    }
    if (!$date) {
        $date = $tmpdate;
    }
    $intervention =~ s/"/\\"/g;
    $intervention =~ s/\\\\/\//g;
    $intervention =~ s/\s*(<\/?t(able|[rdh])[^>]*>)\s*/\1/gi;
    $regfct = $inter2fonction{comparable($intervenant)};
    $regfct =~ s/\W/./gi;
    $intervention =~ s/^<p>[, ]*$regfct[, ]*/<p>/i;
    $cpt+=10;
    $ts = $cpt;
    $out =  '{"commission": "'.$commission.'", "intervention": "'.$intervention.'", "date": "'.$date.'", "source": "'.$source.'", "heure": "'.$heure.'", "session": "'.$session.'", ';
    if ($intervention && $intervenant) {
	if ($intervenant !~ /Collectif Intersexes/i && $intervenant =~ s/ et (M[mes\.]* (l[ea] )?)?(.+)//) {
        $second = $3;
        if ($fonction2inter{comparable($second)}) {
            $second = $fonction2inter{comparable($second)};
        }
	    print $out.'"intervenant": "'.$second.'", "timestamp": "'.$ts.'", "fonction": "'.$inter2fonction{comparable($second)}."\"}\n";
	    $ts++;
	}
	print $out.'"intervenant": "'.$intervenant.'", "timestamp": "'.$ts.'", "fonction": "'.$inter2fonction{comparable($intervenant)}."\"}\n";
    }elsif($intervention) {
	print $out.'"intervenant": "", "timestamp": "'.$ts.'"}'."\n";
    }else {
	return ;
    }
    $commentaire = "";
    $previnterv = $intervenant;
    $intervenant = "";
    $intervention = "";
}

sub setFonction {
    my $fonction = shift;
    my $intervenantorig = shift;
    #print STDERR "FONCTION $fonction | $intervenantorig\n";
    $intervenantorigreg = $intervenantorig;
    $intervenantorigreg =~ s/([()[\].?])/\\\1/g;
    $fonction =~ s/^[Mme\s.]*$intervenantorigreg[, ]*//;
    $fonction =~ s/[\.\s]+$//;
    if ($intervenantorig =~ s/,? et (?:de )?(M[me\.]+(?: \S+)+?)(?:[, ]+(ministre[^<\.]*|[\w\-]*[Pp]r..?sident[^<\.]*))?$// ||
               $fonction =~ s/,? et (?:de )?(M[me\.]+(?: \S+)+?)(?:[, ]+(ministre[^<\.]*|[\w\-]*[Pp]r..?sident[^<\.]*))?$//) {
      if ($2) {
        setFonction($2, $1);
      } else {
        setFonction($fonction, $1);
      }
    } elsif ($intervenantorig =~ s/^M[me.]+ l'(ingénieur.*?) ([A-Z])/\2/) {
      $fonction = ucfirst($1).", $fonction";
    }
    my $intervenant = setIntervenant($intervenantorig);
    if ($intervenant eq $fonction) {
      return $intervenant;
    }
    $fonction =~ s/[^a-zàâéèêëîïôùûü0-9)]+$//i;
    $fonction =~ s/<!--(.*?)-->//g;
    $fonction =~ s/<[^>]+>\s*//g;
    $fonction =~ s/<[^>]*$//;
    $fonction =~ s/([a-z])(\.+|\s*»)+\s*$/\1/;
    $fonction =~ s/(« | »|")//g;
    $fonction =~ s/(\w)\/(\w)/\1-\2/g;
    $fonction =~ s/\///g;
    $fonction =~ s/ pour avise$/ pour avis/;
    $fonction =~ s/, en préalable.*$//;
    $fonction =~ s/,? sur l[ea] pro(jet|proposition de loi).*$//;
    $fonction =~ s/Président/président/;
    $fonction =~ s/(du ministre )+/\1/i;
    $fonction =~ s/\bpésident/président/i;
    $fonction =~ s/général général/général/i;
    $fonction =~ s/rap+or?tr?eur/rapporteur/i;
    $fonction =~ s/co[\-r]*rapporteur/co-rapporteur/i;
    $fonction =~ s/^(.*), \1$/\1/;
    $fonction =~ s/(n°|[(\s]+)$//;
    $fonction =~ s/\s+[0-9][0-9]?\s*$//;
    $fonction =~ s/ de la [com]*mission$//;
    $fonction =~ s/, et discusion .*$//;
    $fonction =~ s/^[\-, ]+//;
    if ($intervenant eq $fonction) {
      return $intervenant;
    }
    if ($intervenant && $fonction =~ /^(ministre( déléguée?)?|président|secrétaire d'[Éé]tat)/i) {
      $shortfonction = $1;
      if ($intervenantorig =~ /\b(M[.me]+) /) {
        $lettre = ($1 eq "M." ? "e" : "a");
        $shortfonction = comparable("$1 l$lettre $shortfonction");
        if (!$fonction2inter{$shortfonction}) {
          #print STDERR "YEAH $shortfonction -> $intervenant\n";
          $fonction2inter{$shortfonction} = $intervenant;
        }
      }
    }
    my $kfonction = comparable($fonction);
    if ($fonction2inter{$kfonction} && !$intervenant) {
        $intervenant = $fonction2inter{$kfonction};
        return $intervenant;
    }
    $fonction2inter{$kfonction} = $intervenant;
    #print STDERR "TEST $kfonction -> $intervenant\n";
    if ($fonction =~ /(ministre déléguée?).*(chargé.*$)/i) {
        $kfonction = comparable("$1 $2");
        $fonction2inter{$kfonction} = $intervenant;
    } elsif ($fonction =~ /[,\s]*suppléant[^,]*,\s*/i) {
        $kfonction = $fonction;
        $kfonction =~ s/[,\s]*suppléant[^,]*,\s*//i;
        $kfonction = comparable($kfonction);
        $fonction2inter{$kfonction} = $intervenant;
    }
    #print "TEST $fonction ($kfonction)  => $intervenant - ".$inter2fonction{$intervenant}."\n";
    $kinterv = comparable($intervenant);
    if (!$inter2fonction{$kinterv} || length($inter2fonction{$kinterv}) < length($fonction) || ($inter2fonction{$kinterv} =~ /président/i && $fonction !~ /président/i) || ($inter2fonction{$kinterv} =~ /rapporteur/i && $fonction !~ /rapporteur/i)) {
	$inter2fonction{$kinterv} = $fonction;
    }
    if ($intervenant =~ / et / && $kfonction =~ s/s$//) {
	$intervenants = $intervenant;
	$intervenants =~ s/ et .*//;
	setFonction($kfonction, $intervenants);
    }
    return $intervenant;
}

sub setIntervenant {
    my $intervenant = shift;
    #print STDERR "TEST1 $intervenant\n";
    $intervenant =~ s/<[^>]+>\s*//g;
    $intervenant =~ s/<[^>]*$//;
    $intervenant =~ s/–/-/g;
    $intervenant =~ s/\s*-\s*$//;
    $kinter = comparable($intervenant);
    if ($fonction2inter{$kinter}) {
        #print STDERR "!FOUND $kinter -> $fonction2inter{$kinter}\n";
        return $fonction2inter{$kinter};
    }
    $intervenant =~ s/^.* de (M(\.|me) )/\1/;
    $intervenant =~ s/^(.........+)\s*M[me.]+ \1/\1/g;
    $intervenant =~ s/Premi/premi/g;
    $intervenant =~ s/president/président/gi;
    $intervenant =~ s/ présidence / présidente /;
    $intervenant =~ s/Erika Bareigts/Ericka Bareigts/i;
    $intervenant =~ s/Joachim Pueyo/Joaquim Pueyo/i;
    $intervenant =~ s/Yaël Braun-Pivert/Yaël Braun-Pivet/i;
    $intervenant =~ s/Jean Louis ([A-ZÉ])/Jean-Louis \1/i;
    $intervenant =~ s/Danielle Obono/Danièle Obono/i;
    $intervenant =~ s/Jean-François Beaugas/Michel Beaugas/i;
    $intervenant =~ s/Marguerite Derprez-Audebert/Marguerite Deprez-Audebert/i;
    $intervenant =~ s/Bruno Gollnish/Bruno Gollnisch/i;
    $intervenant =~ s/Guillaume Pépy/Guillaume Pepy/i;
    $intervenant =~ s/Jean Marc Mompelat/Jean-Marc Mompelat/i;
    $intervenant =~ s/Agnès Guion-Firmin/Claire Guion-Firmin/i;
    $intervenant =~ s/Jean Touzel/Jean Jouzel/i;
    $intervenant =~ s/Jean-Philippe Ardoin/Jean-Philippe Ardouin/i;
    $intervenant =~ s/Fadela Khattabi/Fadila Khattabi/i;
    $intervenant =~ s/Aurélien Taquet/Adrien Taquet/i;
    $intervenant =~ s/Pierre Dharéville/Pierre Dharréville/i;
    $intervenant =~ s/Sabine Tillaye/Sabine Thillaye/i;
    $intervenant =~ s/Céline Untermaier/Cécile Untermaier/i;
    $intervenant =~ s/Yolande de Courson/Yolaine de Courson/i;
    $intervenant =~ s/Jean-Jean-/Jean-/i;
    $intervenant =~ s/Valérie Faure-Muntien/Valéria Faure-Muntian/i;
    $intervenant =~ s/Sandrine Rubin/Sabine Rubin/i;
    $intervenant =~ s/Enerstine/Ernestine/i;
    $intervenant =~ s/Joaquim Son-Forget/Joachim Son-Forget/i;
    $intervenant =~ s/Tiphanie Degois/Typhanie Degois/i;
    $intervenant =~ s/Christine Cloarec[\W]*$/Christine Cloarec-Le Nabour/i;
    $intervenant =~ s/Danièle Brulebois/Danielle Brulebois/i;
    $intervenant =~ s/Yves Cravageot/Yannick Cravageot/i;
    $intervenant =~ s/Giselle Biémouret/Gisèle Biémouret/i;
    $intervenant =~ s/Coline Truong/Céline Truong/i;
    $intervenant =~ s/Isabelle Bouvier/Isabelle Bouyer/i;
    $intervenant =~ s/Nathalia Pouzyreff/Natalia Pouzyreff/i;
    $intervenant =~ s/Murielle Ressiguier/Muriel Ressiguier/i;
    $intervenant =~ s/Jean-Louis Thériot/Jean-Louis Thiériot/i;
    $intervenant =~ s/Patrick Verchère/Patrice Verchère/i;
    $intervenant =~ s/Catherine Proccacia/Catherine Procaccia/i;
    $intervenant =~ s/Laurence Maillard-Méhaignerie/Laurence Maillart-Méhaignerie/i;
    $intervenant =~ s/Fabien Gouttefrade/Fabien Gouttefarde/i;
    $intervenant =~ s/Charles de la Verpillère/Charles de la Verpillière/i;
    $intervenant =~ s/Stanslas Guerini/Stanislas Guerini/i;
    $intervenant =~ s/Natalie Pouzyreff/Natalia Pouzyreff/i;
    $intervenant =~ s/Loïc Prudhomme/Loïc Prud'homme/i;
    $intervenant =~ s/Arnaud Villa/Arnaud Viala/i;
    $intervenant =~ s/Yannick Marignac/Yves Marignac/i;
    $intervenant =~ s/Nicolas Trisse/Nicole Trisse/i;
    $intervenant =~ s/France Henri-Labordère/France Henry-Labordère/i;
    $intervenant =~ s/Philippe Thillaud/Pierre Thillaud/i;
    $intervenant =~ s/Jean Michel Blanquer/Jean-Michel Blanquer/i;
    $intervenant =~ s/ric Pouillat/ric Poulliat/i;
    $intervenant =~ s/Hervé Pelloin/Hervé Pellois/i;
    $intervenant =~ s/E?lisa Hervy/Elsa Hervy/i;
    $intervenant =~ s/Thérèse Majnoni d'Untignano/Thérèse Majnoni d'Intignano/i;
    $intervenant =~ s/Guillaume Garrot/Guillaume Garot/i;
    $intervenant =~ s/Natalie Ancel/Nathalie Ancel/i;
    $intervenant =~ s/Amal[\- ]Amélia Lakf?rafi/Amélia Lakrafi/i;
    $intervenant =~ s/S[iy]ra S[iy]l+a/Sira Sylla/i;
    $intervenant =~ s/Christophe Jer+et+ie/Christophe Jerretie/i;
    $intervenant =~ s/Alexandre Guédon/Xavier Guédon/i;
    $intervenant =~ s/Rémi Rebeyrotte/Rémy Rebeyrotte/i;
    $intervenant =~ s/Sandra Onyszko/Sandra Onyzsko/i;
    $intervenant =~ s/Florian Di Filippo/Fabien Di Filippo/i;
    $intervenant =~ s/Michèle Limon/Monique Limon/i;
    $intervenant =~ s/Antoine Hertz/Antoine Herth/i;
    $intervenant =~ s/Jean-François Mattei/Jean-Paul Mattei/i;
    $intervenant =~ s/Agnès Bono-Vandorme/Aude Bono-Vandorme/i;
    $intervenant =~ s/Jaqcues/Jacques/i;
    $intervenant =~ s/ric Borthorel/ric Bothorel/i;
    $intervenant =~ s/Ian Boucart/Ian Boucard/i;
    $intervenant =~ s/Anissa Kh?edh?er/Anissa Khedher/i;
    $intervenant =~ s/Dimo Cinieri/Dino Cinieri/i;
    $intervenant =~ s/Thibaut Bazin/Thibault Bazin/i;
    $intervenant =~ s/Laeïtitia/Laëtitia/i;
    $intervenant =~ s/Lætitia Avia/Laetitia Avia/i;
    $intervenant =~ s/Florence Povey/Florence Poivey/i;
    $intervenant =~ s/Fabien Di Filipo/Fabien Di Filippo/i;
    $intervenant =~ s/Philipe Herscu/Philippe Herscu/i;
    $intervenant =~ s/Sabine Gaudin/Sandrine Gaudin/i;
    $intervenant =~ s/Michel Pupponi/François Pupponi/i;
    $intervenant =~ s/Michel Castallani/Michel Castellani/i;
    $intervenant =~ s/Emmanuelle Mesnard/Emmanuelle Ménard/i;
    $intervenant =~ s/Marielle Sarnez/Marielle de Sarnez/i;
    $intervenant =~ s/Patrick Silberman/Bruno Silberman/i;
    $intervenant =~ s/Céline Muschotti/Cécile Muschotti/i;
    $intervenant =~ s/Marguerite Bayard/Marguerite Bayart/i;
    $intervenant =~ s/Françoise Nysse\b/Françoise Nyssen/i;
    $intervenant =~ s/Cédric Cédric Villani/Cédric Villani/i;
    $intervenant =~ s/ric Cocquerel/ric Coquerel/i;
    $intervenant =~ s/Céline Rilhac/Cécile Rilhac/i;
    $intervenant =~ s/Bertrand Plancher/Bertrand Pancher/i;
    $intervenant =~ s/Serge Lechtimy/Serge Letchimy/i;
    $intervenant =~ s/Patrick Lavergne/Lionel Lavergne/i;
    $intervenant =~ s/Jean-Baptise Moreau/Jean-Baptiste Moreau/i;
    $intervenant =~ s/Jean-Michel Fanget/Michel Fanget/i;
    $intervenant =~ s/Jean-Bernard Harney/Jean-Bernard Harnay/i;
    $intervenant =~ s/Yvan Koustoff/Yvan Kouskoff/i;
    $intervenant =~ s/Joachim Son-Forge\b/Joachim Son-Forget/i;
    $intervenant =~ s/Mikaël Nogal/Mickaël Nogal/i;
    $intervenant =~ s/Bruno le Vigoureux/Fabrice le Vigoureux/i;
    $intervenant =~ s/Célia Delavergne/Célia de Lavergne/i;
    $intervenant =~ s/Sébastien Huygue/Sébastien Huyghe/i;
    $intervenant =~ s/Julien Hubert-Laferri(e|è)re/Hubert Julien-Laferriere/i;
    $intervenant =~ s/Hubert Julien-Laferrière/Hubert Julien-Laferriere/i;
    $intervenant =~ s/François Gaill/Françoise Gaill/i;
    $intervenant =~ s/Benoît Betinelli/Benoît Bettinelli/i;
    $intervenant =~ s/Élise Fajleges/Élise Fajgeles/i;
    $intervenant =~ s/Agnès Richard-Hibon/Agnès Ricard-Hibon/i;
    $intervenant =~ s/Fabien Lachaud/Bastien Lachaud/i;
    $intervenant =~ s/Lauriane Rossi/Laurianne Rossi/i;
    $intervenant =~ s/Patrick Queneau/Patrice Queneau/i;
    $intervenant =~ s/Maine Sage/Maina Sage/i;
    $intervenant =~ s/Bernard Doroszcsuk/Bernard Doroszczuk/i;
    $intervenant =~ s/Nicole Notta/Nicole Notat/i;
    $intervenant =~ s/Valérie Faure-Muntian/Valéria Faure-Muntian/i;
    $intervenant =~ s/Valérie Dupadt/Valérie Depadt/i;
    $intervenant =~ s/Michel Forget/Michel Fanget/i;
    $intervenant =~ s/Philipple Bolo/Philippe Bolo/i;
    $intervenant =~ s/Laetitia Aviva/Laetitia Avia/i;
    $intervenant =~ s/Raphaeïl Schellenberger/Raphaël Schellenberger/i;
    $intervenant =~ s/Brunos Fuchs/Bruno Fuchs/i;
    $intervenant =~ s/Frnçois/François/i;
    $intervenant =~ s/Yaeïl /Yael /i;
    $intervenant =~ s/Charlotte Lecoq/Charlotte Lecocq/i;
    $intervenant =~ s/Jean-Charles Grelier/Jean-Carles Grelier/i;
    $intervenant =~ s/Christian Byk/Christien Byk/i;
    $intervenant =~ s/Franck Deconinck/Frank Deconinck/i;
    $intervenant =~ s/Sophie Beaudoin-Hubiere/Sophie Beaudouin-Hubiere/i;
    $intervenant =~ s/Fanette Charvier/Fannette Charvier/i;
    $intervenant =~ s/Sébatien /Sébastien /i;
    $intervenant =~ s/Bruno Bettinelli/Benoît Bettinelli/i;
    $intervenant =~ s/Sophie Beaudoin-Hubière/Sophie Beaudouin-Hubiere/i;
    $intervenant =~ s/B(e|é)rang(è|e)re/Bérengère/i;
    $intervenant =~ s/Bérengère (Abba|Couillard)/Bérangère \1/i;
    $intervenant =~ s/Rodrigue Kokuendo/Rodrigue Kokouendo/i;
    $intervenant =~ s/Laurent Desgorge/Laurent Desgeorge/i;
    $intervenant =~ s/Huguette Tiégna/Huguette Tiegna/i;
    $intervenant =~ s/Danièle Rabaté/Danielle Rabaté/i;
    $intervenant =~ s/Mathieu Orphelin/Matthieu Orphelin/i;
    $intervenant =~ s/Sylvain Wasermann/Sylvain Waserman/i;
    $intervenant =~ s/Jean-Paul Lecocq/Jean-Paul Lecoq/i;
    $intervenant =~ s/Fabrice Roussel/Fabien Roussel/i;
    $intervenant =~ s/\bE(tienne|ric|milie|lodie|lisabeth)/é\1/ig;
    $intervenant =~ s/\s*\&\#821[12]\;\s*//;
    $intervenant =~ s/^audition de //i;
    $intervenant =~ s/^(M(\.|me))([^\ss]+)/$1 $3/;
    $intervenant =~ s/\.\s*[\/\|]\s*/, /g;
    $intervenant =~ s/[\|\/\.]//g;
    $intervenant =~ s/\s*[\.\:]\s*$//;
    $intervenant =~ s/Madame/Mme/;
    $intervenant =~ s/Monsieur/M./;
    $intervenant =~ s/et M\. /et M /;
    $intervenant =~ s/^(de )?M[\.me]*s?\s//i;
    $intervenant =~ s/\s*\..*$//;
    $intervenant =~ s/L([ea])\s/l$1 /i;
    $intervenant =~ s/\s+\(/, /g;
    $intervenant =~ s/\)//g;
    $intervenant =~ s/[\.\,\s]+$//;
    $intervenant =~ s/^\s+//;
    $intervenant =~ s/É+/é/gi;
    $intervenant =~ s/\&\#8217\;/'/g;
    $intervenant =~ s/^l'([aeéio])/\U\1/i;
    $intervenant =~ s/^(l[ea] )?d..?put..?e?\s+//i;
    $intervenant =~ s/^(l[ea] )?(rabbin|s..?nat(eur|rice))\s+(.*)$/\4, \2/i;
    $intervenant =~ s/^l[ea] ((co[-\s]*|vice[-\s]*)?présidente?|rapporteure?|[Mm]inistre) (M(\.|me)?\s)?([A-ZÉÈÊÀÂÔÙÛÎÏÇ].*)$/\5, \1/;
    $intervenant =~ s/([A-ZÉÈÊÀÂÔÙÛÎÏÇ][^,\s]+) ([Rr]apporteur|[Pp]résident)/\1, \2/;
    $intervenant =~ s/^P(résidente?) ([A-ZÉÈÊÀÂÔÙÛÎÏÇ].*)$/\2, p\1/;
    #print STDERR "TEST2 $intervenant\n";
    if ($intervenant =~ s/\, (.*)//) {
	setFonction($1, $intervenant);
    }
    if ($intervenant =~ s/^([A-ZÉÈÊÀÂÔÙÛÎÏÇ].+) ?([Ll][ea] )?((([Pp]résident|[Rr]apporteur)[es,\st]*)+)$/\1/) {
        return setFonction($3, $intervenant);
    }
    if ($intervenant =~ /^([a-z]|Dr|Ingénieur|(Géné|Ami|Capo)ral)/) {
	$intervenant =~ s/^l[ea]\s+//i;
	if ($intervenant =~ /((([pP]résident|[rR]apporteur[a-zé\s]+)[\sest,]*)+)([A-Z].*)/) {
        $tmpint = $4;
        $tmpfct = $1;
        if ($tmpint !~ /éral/i) {
        if ($tmpint =~ /commission/i || $tmpfct =~ /commission d['esla\s]+$/i) {
            $tmint = setFonction("$tmpfct $tmpint");
            if ($tmint) {
                return $tmint;
            }
        } else {
	        return setFonction($tmpfct, $tmpint);
	    }
        }
    }
    $kinterv = comparable($intervenant);
    if ($inter2fonction{$kinterv}) {
      return $fonction2inter{comparable($inter2fonction{$kinterv})};
    }
	$conv = $fonction2inter{$kinterv};
    $maybe_inter = "";
	#print STDERR "TEST conv: '$kinterv' '$conv' '$intervenant'\n";
	if ($conv) {
	    $intervenant = $conv;
	}else {
	    $test = lc($intervenant);
        $ktest = comparable($test);
	    foreach $fonction (keys %fonction2inter) { if ($fonction2inter{$fonction}) {
		if ($fonction =~ /^$ktest/i) {
            if ($fonction !~ /délégué/i || $test =~ /délégué/i) {
		        $inter = $fonction2inter{$fonction};
                $maybe_inter = "";
		        last;
            } elsif (!$maybe_inter || ($test =~ /délégué/i && $fonction =~ /délégué/i) || ($test !~ /délégué/i && $fonction !~ /délégué/i)) {
                $maybe_inter = $fonction2inter{$fonction};
            }
		}
	    } }
        if ($maybe_inter) {
            $inter = $maybe_inter;
        }
	    if (!$inter) {
		foreach $fonction (keys %fonction2inter) { if ($fonction2inter{$fonction}) {
            $kfonction = comparable($fonction);
            $kfonction =~ s/ +/.+/g;
		    if ($test =~ /^$kfonction/i) {
			$inter = $fonction2inter{$fonction};
			last;
            }
		} }
	    }
        if ($inter) {
          $intervenant = $inter;
        } else {
          $len = 50;
          while ($len > 10) {
            foreach $fonction (keys %fonction2inter) {
              if ($fonction2inter{$fonction}) {
                $kfonction = substr(comparable($fonction), 0, $len);
                $kfonction =~ s/ +/.+/g;
                if ($ktest =~ /^$kfonction/i) {
                  $intervenant = $fonction2inter{$fonction};
                  $len = 0;
                  last;
                }
              }
            }
            $len -= 2;
          }
        }
      }
    }
    return $intervenant;
}

sub rapporteur
{
    # Si le commentaire peut nous aider à identifier le rapport, on tente
    if ($line =~ /rapport/i && $line !~ /sp..?ciaux|rapporteure?s|grands organismes de recherche/i) {
	if ($line =~ /M[me\.]+\s([^,()]+)(?:,| est proclamée?) (rapporteur[^\)\,\.\;]*)/i) {
        $fct = $2;
        $fct =~ s/\s+et\s+.*$//;
	    setFonction($fct, $1);
	}elsif ($line =~ /rapport de \|?M[me\.]+\s([^,\.\;\|]+)[\,\.\;\|]/i) {
	    setFonction('rapporteur', $1);
	}
    } elsif ($line =~ /ministre/i) {
        $line =~ s/[\r\n]//g;
        @pieces = split(/([,;:]| et|, accompagnée?)+ (de )?M+[mes\.]+ /, $line);
        foreach $li (@pieces) {
            $l = $li;
            $l =~ s/, sur .*$//;
            $l =~ s/, et (à la )?discussion .*$//;
            if ($l ne $line && $l !~ /^[\/\|]?l[ea]s? /i && $l =~ /(M[me\.]+\s)?([^,]+), ([Mm]inistre ((, |et |([dl][eaus'\s]+))*(\S+(\s+|$)){1,4})+)/) {
                setFonction($3, $2);
            }
        }
    }
}

$string =~ s/\r//g;
$string =~ s/<br>\n//gi;
$string =~ s/&#8217;/'/g;
$string =~ s/&#8226;/-/g;
$string =~ s/d\W+évaluation/d'évaluation/g;
$string =~ s/&#339;|œ+/oe/g;
$string =~ s/\|(\W+)\|/$1/g;
$string =~ s/<\/?sup>//ig;
$string =~ s/ +/ /g;
$string =~ s/<p>\|((?:<a name.*?<\/a>)?(?:A(?:vant|près) l')?Article (?:unique|liminaire|\d+e?r?)[^<]*?)\s*\|\s*\/?(.*?)\s*\/?\s*<\/p>/<p>\/$1 $2\/<\/p>/gi;
$string =~ s/<p>\/?((?:<a name.*?<\/a>)?(?:Suspendue à [^,]*, )?L(?:a réunion|a séance|'audition))(, suspendue à .*?,)?\s*(s'achève|se termine|reprend|est (?:suspendue|reprise|levée))(.*?)\/?<\/p>(© Assemblée nationale)?/<p>\/$1$2 $3$4 $5\/<\/p>/gi;
$string =~ s/<p>((?:<a name.*?<\/a>)?(?:En conséquence, )?(?:Le rapport |L['es ]+a(?:rticle|mendement)s* .*?)(?:est|sont)(?: également)?)\s*\|?\s*(sans objet|(?:retir|adopt|rejet)és?\s*)\|?(\s*.*?)<\/p>/<p>\/$1 $2$3\/<\/p>/gi;
$string =~ s/<p>((?:<a name.*?<\/a>)?(?:En conséquence, l|L)['es ]+amendements* [A-Z0-9n].*?tomben?t?)\s*\|?\s*(.*?)<\/p>/<p>\/$1 $2\/<\/p>/g;
$string =~ s/<p>\|([A-Z\W]+)\|<\/p>/<p>\/\1\/<\/p>/g;
$string =~ s/<p>(<a name.*?<\/a>)?((?:(?:Puis,?|Enfin,|Ensuite(?: de quoi)?,?|Par conséquent,|(?:Su(?:r (?:proposition|le rapport)|ivant l'avis)|À l'issue) d[^,]*,)\s*)*)(Elle|La commission(?: d[^<\.]*?)?)((?:[\s\/|]+(?:a|par ailleurs|ensuite))+)?[\s\/|]+((?:désign|autoris|approuv|étudi|nomm|adopt|examin|lev|emis)(?:e|é|,)*)[\s\/|]+(.*?)<\/p>/<p>\/$1$2$3 $4 $5 $6\/<\/p>/gi;
$string =~ s/<p>(<a name.*?<\/a>)?((?:(?:Puis,?|À la demande de certains de ses membres,|Enfin,|Ensuite,|Par conséquent,|(?:Su(?:r (?:proposition|le rapport)|ivant l'avis)|À l'issue) d[^,]*,)\s*)*)(Elle|L'office|La (?:com)?mission(?: d\S+(?: [\wéêè][\wéêè]+)*?,?|, après[^,]*avis[^,]*,)?)[\s\/|]+((?:en vient|passe (?:ensuite )?à|aborde|valide|repousse|se saisit|étudie|est (?:ensuite |alors )?saisie|émet|accept|donne (?:ensuite )?un avis|procède (?:au|à|préalablement)|adopt|rejet+)[eé,]*)[\s\/|]*(.*?)<\/p>/<p>\/$1$2$3 $4 $5\/<\/p>/gi;
$string =~ s/<p[^>]*>[\s(\-]*(((Chap|T)itre |Tome |Volume |(?:Sous-?)?Section |Proposition |Un échange de vues a suivi|Le tableau ci-après|L'ensemble des articles étant rejetés, la proposition [^<]*|Les résultats du scrutin sont les suivants|Après le départ de[^<]* il est procédé |M[M.me]+ .* prête[^<.]* serment\.|L'audition, suspendue à |La réunion (de la commission[^<]*)?(est close|s'achève))[^<]*)\s*<\/p>/<p>\/\1\/<\/p>/gi;
$string =~ s/<p>\s*([- ]*Présidence de M[.me]+ [^<]+|(M[.me]+ [^.]*?[, ]+)+(est|sont) élu[^.]*?\.)\s*<\/p>/<p>\/\1\/<\/p>/gi;
$string =~ s/<p[^>]*>[\(\/]+([^<\/\)]+)[\/\)\.]+<\/p>/\n<p>\/\1\/<\/p>/gi;
$string =~ s/(<td[^>]*>)\n(<p>\/.*?\/<\/p>[\n\s]*<\/td>)/\1\2/gi;
$string =~ s/ission d\W+information/ission d'information/gi;
$string =~ s/à l\W+aménagement /à l'aménagement /gi;
$string =~ s/<a[^>]*href="[^"]*(?:fiche\/OMC_|gouvernement\.fr\/ministre|tribun\/fiches_id|senat\.fr\/senateur\/)[^"]*"[^>]*>([^<]*)<\/a>/\1/g;
$string =~ s/(\|M[.me]+ [^.|]*?\.)\s*(–[^|]*)\|/\1\| \2/g;
$majIntervenant = 0;
$body = 0;

$string =~ s/<\/p><p>/<\/p>\n<p>/gi;
$string =~ s/\|?(Présidence de)\|<\/p>[\s\n]+<p>\|([^<]*?)\|<\/p>[\s\n]+<p>[\|\/\s]+([^<]*président)[\s\|\/]+(<\/p>)/\/\1 \2 \3\/\4/gi;
$string =~ s/[\s\n]*<\/?center>[\s\n]*//gi;
$string =~ s/\s*<\/h(\d+)><\/CRPRESIDENT><CRPRESIDENT><h\1[^>]*>\s*/ /gi;
$string =~ s/(<\/h\d+>)/\1\n/gi;
$string =~ s/(<\/h\d+>)\n(<\/SOMMAIRE>)/\1\2/gi;
$string =~ s/<t([rdh])[^>]*( (row|col)span=["\d]+)+[^>]*>/<t\1\2>/gi;
$string =~ s/<t([rdh])( (row|col)span=["\d]+)*[^>]*>/<t\1\2>/gi;
$string =~ s/\n+\s*(<\/?t(able|[rdh]))/\1/gi;
$string =~ s/<td>[\s\n]*<p[^>]*>(.*?)<\/p>/<td>\1/gi;
$string =~ s/(<\/table>)\s*(<table)/\1\n\2/gi;
$string =~ s/(<table[^>]* )align="(right|left)"([^>]*>)/\1\3/gi;
$string =~ s/(<img[^>]*)[\n\r]+([^>]*>)/\1 \2/gi;
$string =~ s/<a[^>]*href="javascript:[^"]*"[^>]*>([^<]*)<\/a>/\1/gi;
$string =~ s/-->(-->)+/-->/g;
$string =~ s/\.\s*(…|À)\| /.| \1 /g;
$string =~ s/\s*\|\s*(l[ae])\s*\|/ \1 /ig;
$string =~ s/\s*\|\s*et\s*\|\s*(<!|M)/ et \1/ig;
$string =~ s/(M[.me] l[ea] présidente?( \w+){0,2})[\. ]+\1/\1/g;
#$string =~ s/<!-- \.(.*?)\. -->//g;

# Le cas de <ul> qui peut faire confondre une nomination à une intervention :
#on vire les paragraphes contenus et on didascalise
$string =~ s/<\/?ul>//gi;

#print $string; exit;

$finished = 0;
$previnterv = 0;
$listinterv = 0;
foreach $line (split /\n/, $string)
{
    #print STDERR "TEST: ".$line."\n";
    $line =~ s/residen/résiden/ig;
    if ($line =~ /<h[1-9]+/i || $line =~ /"présidence"/ || $line =~ /(Cop|P)résidence de/) {
      if ($line =~ /pr..?sidence[\s\W]+de\s+(M[^<\,]+?)[<,]\s*(pr..?sident d'..?ge)?/i && $line !~ /sarkozy/i) {
        checkout();
        $prez = $1;
        $age = lc($2);
        $prez =~ s/\s*pr..?sident[es\s]*$//i;
        $prez =~ s/\s+et\s+de*\s+M[\.me]+.*$//;
       #print STDERR "Présidence de $prez\n";
        $fct = "président";
        if ($age) {
          $fct = $age;
        } elsif ($prez =~ /^Mm/) {
          $fct .= "e";
        }
        setFonction($fct, $prez);
      }
    }
    if ($line =~ /<body[^>]*>/) {
	$body = 1;
    }
    if ($line =~ /<meta /) {
        if($line =~ /name="NOMCOMMISSION" CONTENT="([^"]+)"/i) {
            $commission_meta = $1;
        }
    }
    next unless ($body);
    if ($line =~ /fpfp/) {
      checkout();
      next;
    }
    if ($line =~ />CONCLUSIONS</) {
      checkout();
      $previnterv = "";
    }
    if ($line =~ /\<[a]/i) {
      if ($line =~ /<a name=["']([^"']+)["']/) {
        $source = $url."#$1";
      } elsif($line =~ /class="menu"/ && $line =~ /<a[^>]+>([^<]+)<?/) {
        $test = $1;
        if (!$commission && $test =~ /Commission|mission/) {
          $test =~ s/\s*Les comptes rendus de la //;
          $test =~ s/^ +//;
          if ($test !~ /(spéciale|enquête|sp|enqu)$/i) {
            $commission = $test;
          }
        }
      }
      $line =~ s/<a name=[^>]*>\s*<\/a>//ig;
      $line =~ s/<a name=[^\/>]\/\s*>//ig;
    }
    if ($line =~ /<h[1-9]+/i) {
        rapporteur();
       #print "$line\n";
        if ($line =~ /SOMseance|"souligne_cra"/i) {
            if ($line =~ /(\d+)\s*(h(?:eures?)?)\s*(\d*)/i) {
                $heure = sprintf("%02d:%02d", $1, $3 || "00");
            }
        }
        if (!$date && $line =~ /SOM(seance|date)|\"seance\"|h2/) {
            if ($line =~ /SOMdate|Lundi|Mardi|Mercredi|Jeudi|Vendredi|Samedi|Dimanche/i) {
              if ($line =~ /(\w+\s+)?(\d+)[erme]*\s+([^\s\d()!<>]+)\s+(\d\d+)/i) {
                $date = sprintf("%04d-%02d-%02d", $4, $mois{lc($3)}, $2);
              }
            }
        }elsif(!$commission && $line =~ /groupe|commission|mission|délégation|office|comité/i) {
            if ($line =~ /[\>\|]\s*((Groupe|Com|Miss|Délé|Offic)[^\>\|]+)[\<\|]/) {
                $commission = $1;
                $commission =~ s/\s*$//;
            }
        }elsif($line =~ /SOMnumcr/i) {
            if ($line =~ /\s0*(\d+)/ && $1 > 1) {
                $cpt = $1*1000000;
            }
        }elsif($line =~ /<\/CRPRéSIDENT>/i) {
            next;
        }
    }

  if ($prez && $line =~ /<\/?t(able|d|h|r)/) {
    $line =~ s/<[^t\/][^>]*>//g;
    $line =~ s/<\/[^t][^>]*>//g;
    $line =~ s/([^<])\/([^<\/]*)\//\1<i>\2<\/i>/g;
    $line =~ s/\|([^|]*)\|/<b>\1<\/b>/g;
    checkout() if ($intervenant || ($line =~ /<table/ && length($intervention) + length($line) gt 2000));
    $intervention .= "$line";
  }elsif ($line =~ /\<p/i || ($line =~ /(<SOMMAIRE>|\<h[1-9]+ class="titre\d+)/i && $line !~ />Commission/)) {
	$found = 0;
    $line =~ s/<\/?SOMMAIRE>/\//g;
    while ($line =~ /^(.*)<(img.*? src=.)(.*?)(['"][^\>]+)>(.*)$/i) {
      $img0 = $1;
      $img1 = $2;
      $img2 = $4;
      $img3 = $5;
      $imgurl = $3;
      if ($imgurl =~ /^\//) {
        $imgurl = $rooturl.$imgurl
      } elsif ($imgurl !~ /^http/i) {
        $imgurl = $baseurl.$imgurl;
      }
      $imgurl =~ s/[\/]/\\\\/g;
      $img2 =~ s/[\\]/\\\\/g;
      $line = $img0."##".$img1.$imgurl.$img2."##".$img3;
    }
    $line =~ s/<[^a\/][^>]*>//g;
    $line =~ s/<\/[^a][^>]*>//g;
    $line =~ s/\s+/ /g;
    $line =~ s/^\s//;
    $line =~ s/\s$//;
    $line =~ s/\s*,\s*\|\s*\/\s*/,|\/ /g;
    $line =~ s/\s*\|\s*,\s*\/\s*/,|\/ /g;
    $line =~ s/\|\|//g;
    $line =~ s/([^:])\/\//\1/g;
    $line =~ s/\s*\/\s*\/\s*$//;
    $line =~ s/^l \|/|l /;
    $line =~ s/\.\| et \|M/ et M/;
    $line =~ s/\/, \/\|\//,|\/ /;
	$line =~ s/##(img[^\>#]+?)##/<\1 \\\\>/ig;
    if ($line =~ /ANNEXE/) {
      $finished = 0;
    }
	next if ($line !~ /\w/);
    next if ($line =~ /\|\/(vice-)?présidente?\/\|/);
    $line =~ s/^\s*–\s*\|\s*/|– /;
    $line =~ s/^\|\s+([A-Z])/|\1/;
    $line =~ s/^\|\s*(Articles?[^|]+)\s*\|\s*(.*)[\s\/]*$/\/\1 \2\//g;
    $tmpinter = "";
    #print STDERR "$intervenant $line\n";
    #si italique ou tout gras => commentaire
    if (($line =~ /^\|.*\|\s*$/ || $line =~ /^\/.*\/\s*$/ || $line =~ /^\/La commission/) && $line !~ /^\|Articles?\s*\d+/i && ($line !~ /^\/\s*«/ || $line =~ /^\/\s*« L'Assemblée/ )) {
      if ($line =~ /^[\/|]((groupe|(com)?mission|délégation|office|comité).*)[\/|]\s*$/i) {
        if (!$timestamp && !$commission) {
          $commission = $1;
          next;
        } elsif (comparable($commission) eq comparable($1)) {
          next;
        }
      }
      if ($intervenant) {
        if (!$tmpinter) {
          checkout();
        }
        if ($line =~ /^\/\(.*\)\/$/){ # || $line =~ /^\|.*\|\s*$/) { # keep interv only for italic not titles
          $tmpinter = $intervenant;
        }
      }
      if ($line =~ /^\|.*\|\s*$/ || $line =~ /^\/(Vu l|[IV]+\.\s|(Puis )?[Ll]a ([Cc]om)?[Mm]ission).*\/$/ || $line =~ /^\/.* suivante?s :\/$/) {
        $previnterv = 0;
      }
      rapporteur();
      $found = 1;
	}
    $line =~ s/^(\|M[.me]+)\s*\|\s*/\1 /;
    $line =~ s/^\|M\s+([A-ZÉ])/|M. \1/;
    $line =~ s/\|\)/)|/g;
    $line =~ s/^(\|M[.me]+[^|.]+\.\s*\|)\/(\«[^\/»]+»)\//\1 \2/g;
    if (($prez && $line =~ /^\|?(Informations? relatives? à |Présences en réunion)/i) || $line =~ /^\W*(Membres )?[Pp]résents/) {
        $finished = 1;
        $tmpinter = "";
        $previnterv = 0;
        checkout();
    } else {
      if ($line !~ /(est nommé|(Mar|Mercre)di)/ && $line =~ s/^\|(M[.me]+s? [^\|\:,]+?)(?:[\|\:](\/[^\/]+?\/)?|((?:,[\|\s]*\/|[\|\s]*\/\s*,\s*)[^\/]+?\/))(.*\w.*)?/\4/) {
        checkout();
        $interv1 = $1;
	    $extrainterv = $2.$3;
        if ($extrainterv =~ s/(Idem|Interprétation|In vino veritas|Quid|« Qui bene amat, bene castigat »…|Errare humanum est, perseverare diabolicum|Cooking Budgets|\/A \w+i\W*\/)//) {
            $line = $1.$line;
        }
        $found = $majIntervenant = 1;
        $intervenant = setIntervenant($interv1.$extrainterv);
	  } elsif ($line !~ /^\|\/?(?:&#\d+;|–|-|Ø|Ê)?\s*(?:Puis de |Action|Figure|Échanges?|AMÉLIORER|Travaux |Missions|Examen|Politique|RENFORCE|Mesures|Désignation|Réunion|Examen|Compte[\-\s]rendu|Mission|CONSTRUIRE|Adapter|Clarifier|Communication|Echange de vues|Marges de |de |Ateliers? |(\S+ )?Table ronde|Premiers? échange|En conséquence|Dispositions|Audition|Organisation|Présentation|Nomination|Commission|Accords?|Anciens|[co\-]*Présidence|Titre|Chapitre|(?:Sous-?)?Section|Après|Avant|Articles?|[^|]*pro(jet|proposition) de (loi|résolution))/i &&
          ($line =~ s/^\|([^\|,]+)\s*,\s*([^\|]+)\|// || $line =~ s/^(M(?:me|\.)\s[^\/,]{,80})(?:\/\s*,|,\s*\/)[\/,\s]*([^\.]+)[\.][\/\s]*//)) {
        checkout();
        $found = $majIntervenant = 1;
	    $intervenant = setFonction($2, $1);
	  } elsif ($line =~ s/^\|((Une?|Plusieurs) (membres de |députés?).*?)[\.\s:]*\|//) {
        checkout();
        $found = $majIntervenant = 1;
	    $intervenant = setIntervenant($1);
	  } elsif ($line =~ s/^\|(Réponse)[\.\s:|]*//) {
        checkout();
        $found = $majIntervenant = 1;
	    $intervenant = setIntervenant($1);
	  } elsif ($line =~ s/^(?:(?:Madame|Monsieur|[Ll][ea]|\|)\s*)+([pP]résidente?) (([A-ZÉ][^\.: \|]+ ?|de )+)[\.:\|]+\s*//) {
		$f = $1;
		$i = $2;
		$found = $majIntervenant = 1;
        checkout();
        $intervenant = setFonction($f, $i);
	  } elsif ($line =~ s/^([Llea\s]*\|[Llea\s]*([pP]r..?sidente?|[rR]apporteure?)\s*[\.:\|]+)\s*//) {
        $orig = $1;
		$tmpfonction = lc($2);
        if (!$intervenant && $intervention =~ /:<\/p>$/) {
            $line = "$orig$line";
        } else {
		    $tmpintervenant = $fonction2inter{comparable($tmpfonction)};
		    if ($tmpintervenant) {
                checkout();
			    $intervenant = $tmpintervenant;
			    $found = $majIntervenant = 1;
		    }
        }
      }
	}
	$line =~ s/^\s+//;
    if ($line =~ /(<a|https?:\/\/)/i) {
      $line =~ s/\|//g;
      while ($line =~ /(href="|https?:)[^"]*\//) {
        $line =~ s/((href="|https?:)[^"]*)\//\1ø%ø/;
      }
      while ($line =~ /(href="|https?:)[^>]*>[^<]*\//) {
        $line =~ s/((href="|https?:)[^>]*>[^<]*)\//\1ø%ø/;
      }
      $line =~ s/([^<])\//\1/g;
      $line =~ s/ø%ø/\//g;
    } else {
      $line =~ s/[\|\/]//g;
    }
    $line =~ s/\/\.\//./g;
    $line =~ s/^[\.\:]\s*//;
    $line =~ s/é\.e\.s\b/é·e·s/ig;
    #print STDERR "LINE: $found $intervenant $line\n";
	if (!$found && !$finished && $line !~ /^\s*M(mes?|[e\.]|adame|onsieur)\s+([^\.:]*(interroge|, pour le rapport|consacre|va |a souhaité|expliqu|est également|la parole|propose|a p(ubli|os)é|a mené|est nommé|convié|souhaite|répond|question|soulève|empêché|faire part| (est|été) nommé|avait assuré|a ainsi |aurait |était accompagné|travaille i|, ont|, veuillez|, j'entends|, (nous|je) vous |, merci |, vous|ayant )|[^:]*présentent)/) {
	    if ($line =~ s/^\s*((?:\s*(Dr\.?|S(on|\.) Exc\.?|Sir|Pr(\.?|ofesseur)|Maître|L[ea] représentante?|Une auditrice|Une intervenante|Ingénieur|Colonel|(Géné|Ami|Capo)ral|M(mes?|adame|onsieur|[e\.])))+(\s([dl][eaus'\s]+)*[^\.:\s]{2,}){1,4})([\.:])//) {
            $tmpi = $1;
            $orig = $1.$7;
            if (!$intervenant && $line =~ /^\s*$/) {
                $line = $orig;
            } else {
                checkout();
                $intervenant = setIntervenant($tmpi);
            }
        } elsif ($line =~ s/^\s*(M(mes?|\.)\s+[A-ZÉ][^,]*?), ((secrétaire|ministre|députée?|(?:direct|sénat)(?:eur|rice)|rapporteur|président)[^«\d]*?[^M])\.\s*//) {
            checkout();
            $intervenant = setFonction($3, $1);
	    }elsif (!$majIntervenant) {
            if ($line =~ s/^\s*(M(mes?|[e\.])\s[A-Z][^\s\,]+\s*([A-Z][^\s\,]+\s*|de\s*){2,})// ) {
                $orig = $1;
                if (!$intervenant && $line =~ /^\s*$/) {
                    $line = $orig;
                } else {
        	        checkout();
    	            $intervenant = setIntervenant($orig);
                }
            }elsif($line =~ s/^\s*[Ll][ea] ([pP]r[ée]sidente?) (([A-ZÉ][^\.: \|]+ ?)+)[\.: \|]*//) {
                setFonction($1, $2);
                checkout();
                $intervenant = setIntervenant($2);
            }
	    }
	}
    if (!$found && !$finished && !$intervenant && $previnterv) {
        $tmpprev = $previnterv;
        checkout();
        $intervenant = $tmpprev;
    }
    if ($line && !$listinterv) {
	  $intervention .= "<p>$line</p>";
    }
    if ($line =~ /^(Est|Sont?) ([a-z]+ ){0,3}intervenu[^.:<]*\s*:\s*$/) {
      $listinterv = 1;
    }
    if ($line =~ /^Ont participé (?:au débat|à la discussion)\s*:\s*(M.*?)[\s\.]*$/) {
      foreach $part (split(/\s*(?:,| et)\s+/, $1)) {
        checkout();
        $intervenant = setIntervenant($part);
        $intervention = "<p><i>(non disponible)</i></p>";
        checkout();
      }
    }
    if ($line =~ /Après les interventions de (M[Mme.s]+.*), (le président|la (com)?mission) /) {
      foreach $part (split(/\s*(?:,| et(?: du)?)\s+/, $1)) {
        checkout();
        $intervenant = setIntervenant($part);
        $intervention = "<p><i>(non disponible)</i></p>";
        checkout();
      }
    }
    if ($listinterv && !$finished && $line =~ /^(?:&#8211;)?\s*(M[.me]+\s+[A-ZÉ][^\.]+)([\s\.;]*)$/) {
      checkout();
      $intervenant = setIntervenant($1);
      $intervention = "<p><i>(non disponible)</i></p>";
      checkout();
      if ($listinterv && $2 =~ /\./) {
        $listinterv = 0;
      }
    }
    if ($line =~ /(https?.*?(assnat\.fr|videos?\.assemblee-nationale\.(fr|tv)|assemblee-nationale\.tv)\/[^\s"<>]*)([\s"<>]|\.$|$)/ && ($line !~ /commission-elargie/ || $source =~ /commissions_elargies/)) {
      $urlvideo = $1;
      if ($2 eq "assnat.fr" || $urlvideo =~ /\/direct\./) {
        $origurl = $urlvideo;
        use WWW::Mechanize;
        $mech = WWW::Mechanize->new(autocheck => 0);
        $mech->max_redirect(1);
        $mech->get($urlvideo);
        $urlvideo = $mech->response()->header('Location');
        if (!$urlvideo) {
          $mech2 = WWW::Mechanize->new(autocheck => 0);
          $mech2->max_redirect(0);
          $mech2->get($origurl);
          $urlvideo = $mech2->response()->header('Location');
        }
        if ($urlvideo !~ /assemblee-nationale\.(fr|tv)/) {
          $urlvideo =~ s/^\/+//;
          $urlvideo = "https://videos.assemblee-nationale.fr/$urlvideo";
        }
        $pos = index($intervention, $origurl);
        while($pos > -1) {
          substr($intervention, $pos, length($origurl), $urlvideo);
          $pos = index($intervention, $origurl, $pos + length($urlvideo));
        }
      }
      checkout();
      $tmpsource = $source;
      $source = $urlvideo;
      # no video iframe until AN.tv has a valid https certificate...
      #$urlvideo =~ s/http:/https:/i;
      #$intervention = "<p><iframe height=\"660px\" width=\"100%\" src=\"$urlvideo\"></iframe></p>";
      #checkout();
      if ($urlvideo =~ /assemblee-nationale.*\/video\.([^.]+)/) {
        $idvideo = $1;
        $urlsommairevid = "http://videos.assemblee-nationale.fr/Datas/an/$idvideo/content/data.nvs";
        use WWW::Mechanize;
        use HTML::Entities;
        $mech = WWW::Mechanize->new();
        $mech->get($urlsommairevid);
        $sommairevid = $mech->content;
        $nointer = "<p><i>(disponible uniquement en vidéo)</i></p>";
        while ($sommairevid =~ s/<chapter[^>]*label="\s*([^"]+)\s*"[^>]*>//) {
          $element = decode_entities($1);
          utf8::encode($element);
          $element =~ s/\s+/ /g;
          $element =~ s/^MM\./M. /;
          $element =~ s/^M\.(\S+)/M. \1/;
          $element =~ s/(\S+)\s*\(\s*/\1 (/;
          $element =~ s/(\S+)(chef d)/\1, \2/;
          if ($element =~ /^M(?:\.|me)?\s+([^,]+),\s*(.*)$/ || $element =~ /^((?:(?:Col|Général|François-Joseph|Capitaine|Major|Ga?l|S[.\s]+E(?:[.\s]+M)?|Son Excellence|[PD]r)[. ]+)+[^,]+),\s*(.*)$/) {
            checkout();
            $intervenant = setFonction($2, $1);
            $intervention = $nointer;
            checkout();
          } elsif ($element =~ /^M(?:\.|me)?\s+(.*)$/ || $element =~ /^((?:(?:Col|Général|Capitaine|Major|Ga?l|S[.\s]*E(?:[.\s]+M)?|Représentant[es]*|Son Exc(\.|ellence)|[DP]r)[. ]+)+.*)$/) {
            checkout();
            $intervenant = setIntervenant($1);
            $intervention = $nointer;
            checkout();
          } elsif ($element !~ /^Intervention$/i) {
            $intervenant = "";
            $intervention .= "<p>$element</p>";
          }
        }
        $previnterv = 0;
      }
      $source = $tmpsource;
    }
  }
    while ($intervention =~ s/((<table[^>]*><tr>.*?<\/tr>).{30000,32000}<\/tr>)\s*(<tr.*<\/table>.*)$/\1/i) {
        $tmpinter = $intervenant;
        $moretable = '<p>'.$2.$3;
        $intervention .= '</table></p>';
        checkout();
        $intervention = $moretable;
        if ($tmpinter) {
            checkout();
            $intervenant = $tmpinter;
        }
    }
    if (length($intervention) > 32000) {
        $tmpinter = $intervenant;
        checkout();
    }
    if ($tmpinter) {
        checkout();
        $intervenant = $tmpinter;
    }
    if ($line =~ /(réunion|séance) (s'achève|est levée)/i) {
        $finished = 1;
        $tmpinter = "";
    }
}
checkout();
