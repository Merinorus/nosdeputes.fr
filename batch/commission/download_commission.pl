#!/usr/bin/perl

use WWW::Mechanize;
use HTML::TokeParser;

$legislature = shift || 15;
$start = shift || '0';
$count = 50;

$a = WWW::Mechanize->new(autocheck => 0);
#$a->post("http://www2.assemblee-nationale.fr/recherche/resultats_recherche/%28tri%29/date/%28query%29/YTo3OntzOjE6InEiO3M6NDY6InR5cGVEb2N1bWVudDoiY29tcHRlIHJlbmR1IiBhbmQgY29udGVudTpjb21wdGUiO3M6NDoicm93cyI7aToxMDA7czo1OiJzdGFydCI7aTowO3M6Mjoid3QiO3M6MzoicGhwIjtzOjI6ImhsIjtzOjU6ImZhbHNlIjtzOjI6ImZsIjtzOjE5NzoidXJsLHRpdHJlLHVybERvc3NpZXJMZWdpc2xhdGlmLHRpdHJlRG9zc2llckxlZ2lzbGF0aWYsdGV4dGVRdWVzdGlvbix0eXBlRG9jdW1lbnQsc3NUeXBlRG9jdW1lbnQscnVicmlxdWUsdGV0ZUFuYWx5c2UsbW90c0NsZXMsYXV0ZXVyLGRhdGVEZXBvdCxzaWduYXRhaXJlc0FtZW5kZW1lbnQsZGVzaWduYXRpb25BcnRpY2xlLHNvbW1haXJlLHNvcnQiO3M6NDoic29ydCI7czowOiIiO30=");
$a->post("http://www2.assemblee-nationale.fr/recherche/resultats_recherche/(legislature)/15/(tri)/date/(query)/eyJxIjoidHlwZURvY3VtZW50OlwiY29tcHRlIHJlbmR1XCIgYW5kIGNvbnRlbnU6YSIsInJvd3MiOjEwLCJzdGFydCI6MCwid3QiOiJwaHAiLCJobCI6ImZhbHNlIiwiZmwiOiJ1cmwsdGl0cmUsdXJsRG9zc2llckxlZ2lzbGF0aWYsdGl0cmVEb3NzaWVyTGVnaXNsYXRpZix0ZXh0ZVF1ZXN0aW9uLHR5cGVEb2N1bWVudCxzc1R5cGVEb2N1bWVudCxydWJyaXF1ZSx0ZXRlQW5hbHlzZSxtb3RzQ2xlcyxhdXRldXIsZGF0ZURlcG90LHNpZ25hdGFpcmVzQW1lbmRlbWVudCxkZXNpZ25hdGlvbkFydGljbGUsc29tbWFpcmUsc29ydCIsInNvcnQiOiIifQ==");
$content = $a->content;
$p = HTML::TokeParser->new(\$content);
while ($t = $p->get_tag('a')) {
  $txt = $p->get_text('/a');
  $curl = $file = $t->[1]{href};
  if ($txt =~ /compte rendu|e nationale \~/i && $curl !~ /(\/cri\/(2|congres)|\(typeDoc\))/ && $curl =~ /nationale\.fr\/$legislature\//) {
    $ok = 1;
    $file =~ s/\//_/gi;
    $file =~ s/\#.*//;
    $curl =~ s/[^\/]+$//;
    $url{$curl} = 1;
    next if -e "html/$file";
    print "$file\n";
    $a->get($t->[1]{href});
    open FILE, ">:utf8", "html/$file.tmp";
    print FILE $a->content;
    close FILE;
    rename "html/$file.tmp", "html/$file";
    $a->back();
  }
}
@url = keys %url;

$lastyear = localtime(time);
$lastyear =~ s/^.*\s(\d{4})$/$1/;
$lastyear++;
$startyear = $legislature * 5 + 1942;
for $year ($startyear .. $lastyear) {
  $session = sprintf('%02d-%02d', $year-2001, $year-2000);
  push(@url, "http://www.assemblee-nationale.fr/$legislature/cr-cedu/$session/index.asp");
  push(@url, "http://www.assemblee-nationale.fr/$legislature/cr-eco/$session/index.asp");
  push(@url, "http://www.assemblee-nationale.fr/$legislature/cr-cafe/$session/index.asp");
  push(@url, "http://www.assemblee-nationale.fr/$legislature/cr-soc/$session/index.asp");
  push(@url, "http://www.assemblee-nationale.fr/$legislature/cr-cdef/$session/index.asp");
  push(@url, "http://www.assemblee-nationale.fr/$legislature/cr-dvp/$session/index.asp");
  push(@url, "http://www.assemblee-nationale.fr/$legislature/cr-cfiab/$session/index.asp");
  push(@url, "http://www.assemblee-nationale.fr/$legislature/cr-cloi/$session/index.asp");
  push(@url, "http://www.assemblee-nationale.fr/$legislature/budget/plf$year/commissions_elargies/cr/");
  push(@url, "http://www.assemblee-nationale.fr/$legislature/cr-mec/$session/index.asp");
  push(@url, "http://www.assemblee-nationale.fr/$legislature/cr-mecss/$session/index.asp");
  push(@url, "http://www.assemblee-nationale.fr/$legislature/cr-cec/$session/index.asp");
  push(@url, "http://www.assemblee-nationale.fr/$legislature/cr-oecst/$session/index.asp");
  push(@url, "http://www.assemblee-nationale.fr/$legislature/cr-delf/$session/index.asp");
  push(@url, "http://www.assemblee-nationale.fr/$legislature/cr-dom/$session/index.asp");
}
push(@url, "http://www.assemblee-nationale.fr/$legislature/europe/c-rendus/index.asp");
if ($legislature == 13) {
  push(@url, "http://www.assemblee-nationale.fr/13/cr-micompetitivite/10-11/index.asp");
  push(@url, "http://www.assemblee-nationale.fr/13/cr-micompetitivite/11-12/index.asp");
  push(@url, "http://www.assemblee-nationale.fr/13/cr-mitoxicomanie/10-11/index.asp");
  push(@url, "http://www.assemblee-nationale.fr/13/cr-cegrippea/09-10/");
} elsif ($legislature == 14) {
  push (@url, "http://www.assemblee-nationale.fr/14/cr-csprogfinances/11-12/index.asp");
  push (@url, "http://www.assemblee-nationale.fr/14/cr-csprogfinances/12-13/index.asp");
  push (@url, "http://www.assemblee-nationale.fr/14/cr-csprostit/13-14/index.asp");
  push (@url, "http://www.assemblee-nationale.fr/14/cr-cesidmet/12-13/index.asp");
  push (@url, "http://www.assemblee-nationale.fr/14/cr-mimage/12-13/index.asp");
  push (@url, "http://www.assemblee-nationale.fr/14/cr-micoutsprod/11-12/index.asp");
  push (@url, "http://www.assemblee-nationale.fr/14/cr-micoutsprod/12-13/index.asp");
  push (@url, "http://www.assemblee-nationale.fr/14/cr-misimplileg/13-14/index.asp");
  push (@url, "http://www.assemblee-nationale.fr/14/cr-miecotaxe/13-14/index.asp");
  push (@url, "http://www.assemblee-nationale.fr/14/cr-cefugy/12-13/index.asp");
  push (@url, "http://www.assemblee-nationale.fr/14/cr-cefugy/13-14/index.asp");
  push (@url, "http://www.assemblee-nationale.fr/14/cr-cesncm/12-13/index.asp");
  push (@url, "http://www.assemblee-nationale.fr/14/cr-cesncm/13-14/index.asp");
  push (@url, "http://www.assemblee-nationale.fr/14/cr-ceaffcahuzac/12-13/index.asp");
  push (@url, "http://www.assemblee-nationale.fr/14/cr-ceaffcahuzac/13-14/index.asp");
  push (@url, "http://www.assemblee-nationale.fr/14/cr-cenucleaire/13-14/index.asp");
} elsif ($legislature == 15) {
  push (@url, "http://www.assemblee-nationale.fr/15/cr-miaidenf/18-19/index.asp");
}

$a = WWW::Mechanize->new(autocheck => 0);
foreach $url (@url) {
  $cpt = 0;
  $a->get($url);
  $content = $a->content;
  $p = HTML::TokeParser->new(\$content);
  while ($t = $p->get_tag('a')) {
    $txt = $p->get_text('/a');
    if ($txt =~ /compte rendu|mission/i && $t->[1]{href} =~ /\d\.asp/) {
      $a->get($t->[1]{href});
      $file = $a->uri();
      $file =~ s/\//_/gi;
      $file =~ s/\#.*//;
      #$file =~ s/commissions_elargies_cr_c/commissions_elargies_cr_C/;
      $file =~ s/commissions_elargies_cr_C/commissions_elargies_cr_c/;
      $size = -s "html/$file";
      if ($size) {
        $cpt++;
        #last if ($cpt > 3);
        next;
      }
      print "$file\n";
      open FILE, ">:utf8", "html/$file";
      print FILE $a->content;
      close FILE;
      $a->back();
    }
  }
}
