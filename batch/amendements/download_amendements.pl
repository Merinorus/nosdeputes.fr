#!/usr/bin/perl

use Date::Format;
use WWW::Mechanize;
use HTML::TokeParser;
$count = 0;
$count2 = 0;

$day = time2str("%d", time);
$month = time2str("%m", time);
$year = time2str("%Y", time);
$datefin = "01%2F01%2F".($year+1);
if ($day > 14) { $day -= 14; }
else {
    $day += 14;
    if ($month == 1) { $month = 12; $year--; }
    else { $month--; }
}
$datedebut = sprintf('%02d', $day)."%2F".sprintf('%02d', $month)."%2F".$year;

$url = "http://recherche2.assemblee-nationale.fr/amendements/resultats.jsp?ResultMaxDocs=5000&LEGISLATURE=13Amendements&NUM_INIT=&NUM_AMEND=&AUTEUR=&DESIGNATION_ARTICLE=&DESIGNATION_ALINEA=&DELIBERATION=&SORT_EN_SEANCE=&NUM_PARTIE=&DateDebut=".$datedebut."&DateFin=".$datefin."&periode=&Scope=TEXTEINTEGRAL&SortField=DATE&SortOrder=Desc&format=HTML&ResultCount=5000&ResultStart=1&QueryText=&typeEcran=";

#$url = "http://recherche2.assemblee-nationale.fr/amendements/resultats.jsp?ResultMaxDocs=5000&LEGISLATURE=13Amendements&NUM_INIT=&NUM_AMEND=&AUTEUR=&DESIGNATION_ARTICLE=&DESIGNATION_ALINEA=&DELIBERATION=&SORT_EN_SEANCE=&NUM_PARTIE=&DateDebut=01%2F08%2F2009&DateFin=15%2F10%2F2009&periode=&Scope=TEXTEINTEGRAL&SortField=DATE&SortOrder=Desc&format=HTML&ResultCount=5000&ResultStart=1&QueryText=&typeEcran=";

$a = WWW::Mechanize->new();
$a->get($url);
$content = $a->content;
$p = HTML::TokeParser->new(\$content);

while ($t = $p->get_tag('a')) {
    if ($t->[1]{class} eq 'lienamendement') {
	$htmfile = $t->[1]{href};
	next if ($htmfile =~ /(index|javascript)/);
        $count++;
	$a->get($htmfile);
	$htmfile =~ s/\//_/gi;
	$htmfile =~ s/\#.*//;
	print "  $htmfile ... ";
	open FILE, ">:utf8", "html/$htmfile";
	print FILE $a->content;
	close FILE;
	print "downloaded.\n";
	$a->back();
    }
}
print $count." amendements pour les deux dernières semaines";

open(FILE, 'liste_sort_indefini.txt') ;
@string = <FILE>;
$string = "@string";
close FILE;

foreach $line (split /\n/, $string) {
    $htmfile = $line;
    next if ($htmfile =~ /source/);
    $count2++;
    $a->get($line);
    $htmfile =~ s/\//_/gi;
    $htmfile =~ s/\#.*//;
    print "  $htmfile ... ";
    open FILE, ">:utf8", "html/$htmfile";
    print FILE $a->content;
    close FILE;
    print "downloaded.\n";
    $a->back();
}

print $count2." amendements au sort encore indéfini";
print $count+$count2." amendements téléchargés";

