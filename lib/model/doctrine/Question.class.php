<?php

/**
 * This class has been auto-generated by the Doctrine ORM Framework
 */
class Question extends BaseQuestion
{
  public function getLink() {
    if (!function_exists('url_for'))
      sfProjectConfiguration::getActive()->loadHelpers(array('Url'));
    return url_for('@question_numero?numero='.$this->numero.'&legi='.$this->legislature);
  }
  public function getPersonne() {
    return $this->getParlementaire()->getNom();
  }

  public function __toString() {
    $str = substr(strip_tags($this->question), 0, 250);
    if (strlen($str) == 250) {
      $str .= '...';
    } else if (!$str) $str = "";
    return $str;
  }

  public function getLastDate() {
    if ($this->date_cloture)
      return $this->date_cloture;
    return $this->date;
  }

  public function getShortTitre() {
    return myTools::displayVeryShortDate($this->date).'&nbsp;&mdash; '.$this->uniqueMinistere().'&nbsp;- '.$this->_get('titre');
  }

  public function getFullTitre() {
    $titre = $this->type.' N° '.self::shortenize($this->numero).' du '.myTools::displayVeryShortDate($this->date).' ('.$this->uniqueMinistere().')';
    if ($this->motif_retrait === "caduque") $titre .= ' (Caduque)';
    else if ($this->motif_retrait || ($this->date_cloture && !$this->reponse && date("Y-m-d") > $this->date_cloture)) $titre .= ' (Retirée)';
    else if (!$this->reponse) $titre .= ' (Sans réponse)';
    else $titre .= ' (Réponse le '.myTools::displayVeryShortDate($this->date_cloture).')';
    return $titre;
  }

  public function setAuteur($sen) {
    if (preg_match('/^(.*) - (.*) - (.*) - (.*)$/', $sen, $match))
      $senateur = Doctrine::getTable('Parlementaire')->findOneByNomSexeGroupeCirco($match[1], $match[2], $match[4], $match[3]);
    else $senateur = Doctrine::getTable('Parlementaire')->findOneByNom($sen);
    if (!$senateur) print "ERROR: Auteur introuvable in ".$this->source." : $sen\n";
    else {
      $this->_set('parlementaire_id', $senateur->id);
      $senateur->free();
    }
  }

  public static function shortenize($num) {
    return preg_replace('/^0+/', '', preg_replace('/^\d*[a-z]/i', '', $num));
  }

  public function getShortNum() {
    return self::shortenize($this->numero);
  }

  public function uniqueMinistere() {
    $ministere = str_replace('Secrétariat d\'État auprès du ', '', $this->ministere);
    $ministere = str_replace('délégué à', 'de', $ministere);
    $ministere = str_replace('délégué au', 'du', $ministere);
    $ministere = str_replace('délégué aux', 'des', $ministere);
    $ministere = str_replace('chargé', '', $ministere);
    $ministere = str_replace('de la mise en oeuvre', '', $ministere);
    $ministere = preg_replace('/^([^,]+),.*$/', '\\1', $ministere);
    if (preg_match('/^((Ministère|Haut-Commissariat|Secrétariat d\'État) ((à|de) l\'|(à la|au|aux|du|des|de la) ))(affaires|espace|fonction|collectivités|cohésion|sécurité|anciens|enseignement|éducation|commerce)(( *[^ ]+) +$)/', $ministere, $match))
      $ministere = $match[1].$match[6].$match[7];
    else if (preg_match('/petites et moyennes entreprises/', $ministere))
      $ministere = preg_replace('/(petites et moyennes entreprises).*$/', '\\1', $ministere);
    else if (! preg_match('/(français de l\'étranger|plan de relance|politique de la ville|aménagement du territoire|relations avec le parlement)/', $ministere))
      $ministere = preg_replace('/^(Ministère|Haut-Commissariat|Secrétariat d\'État) ((à|de) l\'|(à la|au|aux|du|des|de la) )([^ ]+) +.*$/', '\\1 \\2\\5', $ministere);
    return preg_replace('/[\s,]+$/', '', $ministere);
  }

  public function setQuestion($question, $rappel=-1, $transformee_en=-1) {
    $question = preg_replace("/<a href='([^']+)'>/i", '<a href="\\1">', $question);
    if (preg_match('/^(\d{2})\d{2}(\d{4,5})([\dA-Z]?)$/', $rappel, $match)) {
      $annee = $match[1]; $num = $match[2]; $lettre = $match[3];
      $shortnum = preg_replace('/^0+/', '', $num);
      $id = $lettre;
      if ($lettre) $id = $annee.$lettre;
      $shortid = $id.$shortnum;
      $id .= $num;
      $question = preg_replace("/(question[^<\.]+)n\s*°\s*0*($shortnum\/?$lettre)/i", '<a href="##Q'.$id.'##">\\1N°&nbsp;'.$shortid.'</a>', $question);
    }
    if (preg_match('/^(\d{2})\d{2}(\d{4,5})([\dA-Z]?)$/', $transformee_en, $match)) {
      $annee = $match[1]; $num = $match[2]; $lettre = $match[3];
      $shortnum = preg_replace('/^0+/', '', $num);
      $id = $lettre;
      if ($lettre) $id = $annee.$lettre;
      $shortid = $id.$shortnum;
      $id .= $num;
      $question = '<p><em>Cette question a été transformée en <a href="##Q'.$id.'##">question N°&nbsp;'.$shortid.'</a>.</em></p>'.$question;
    }
    $this->_set('question', $question);
  }

  public function getQuestionRiche() {
    if (!function_exists('url_for'))
      sfProjectConfiguration::getActive()->loadHelpers(array('Url'));
    $question = $this->_get('question');
    if (preg_match_all('/##Q(\d*[ACEGS]?\d+)##/', $question, $match)) foreach ($match[1] as $q) {
      $url = url_for('@question_numero?legi='.$this->legislature.'&numero='.$q);
      $question = str_replace('##Q'.$q.'##', $url, $question);
    }
    if ($this->type != "Question écrite")
      $question = self::clean_texte_oral($question);
    return $question;
  }

  public static function clean_texte_oral($txt) {
    $txt = preg_replace('/(\([^\)]*\)[\s\.]*)<\/p>/', '<br/><em>\\1</em></p>', $txt);
    $txt = preg_replace('/<p>(La parole[^<]+)<\/p>/', '<p><em>\\1</em></p>', $txt);
    $txt = preg_replace('/<p>(M[\.mle]+ [^\.]+\.[^<])/', '<p><b>\\1</b>', $txt);
    return $txt;
  }

  public function setReponse($reponse) {
    $reponse = preg_replace("/<a href='([^']+)'>/", '<a href="\\1">', $reponse);
    $this->_set('reponse', $reponse);
  }

  public function getReponseRiche() {
    if (!function_exists('url_for'))
      sfProjectConfiguration::getActive()->loadHelpers(array('Url'));
    $reponse = $this->_get('reponse');
    if ($this->type === "Question écrite" && preg_match("/<p>([^<]+question[^<\.]+n\s*°\s*(\d+\/?[ACEGS]?)[^<]*)<\/p>/i", $reponse, $match)) {
      $parag = $match[1];
      $numero = $match[2];
      $shortnum = preg_replace('/\//', '', preg_replace('/^0+/', '', $numero));
      if (preg_match('/([dD][ée]put[ée]|AN|[aA]ssembl[ée]\s*[nN]ationale)/', $parag))
        $link = "http://www.nosdeputes.fr/question/QE/".$shortnum;
      else {
        $shortnumorder = preg_replace('/^(\d+)([a-z])$/i', '\\2\\1', $shortnum);
        $link = url_for('@question_numero?legi='.$this->legislature.'&numero='.$shortnumorder);
      }
      $reponse = preg_replace("/(question[^<]+)n\s*°\s*$numero/", '<a href="'.$link.'">\\1N°&nbsp;'.$shortnum, $reponse);
    }
    if ($this->type != "Question écrite") {
      $reponse = self::clean_texte_oral($reponse);
      if (preg_match('/<a href="[^"#]+(senat\.fr\/seances\/[^"#]+)(#[^"]+)?">Voir le compte rendu de la séance/', $reponse, $match)) {
        $urlseance = "http://www.".$match[1];
// $itv = SQL select seance_id, section_id from intervention where source like $urlseance
      }
      $itv = "";
      if (!$itv) {
        $debut_reponse = $reponse;
// SQL find seance correspondante from debut réponse et date autour date_reponse
      }
      if ($itv)
        return preg_replace('/<a[^>]+>[^<]+</a>', '<a href="'.url_for('@seance?id='.$itv->seance_id).'#table_'.$itv->section_id.'">Voir le compte rendu de la séance.</a>', $reponse);
    }
    return $reponse;
  }

}
