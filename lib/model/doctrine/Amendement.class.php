<?php

/**
 * This class has been auto-generated by the Doctrine ORM Framework
 */
class Amendement extends BaseAmendement {

  public function getLink() {
    sfProjectConfiguration::getActive()->loadHelpers(array('Url'));
    return url_for('@amendement?loi='.$this->texteloi_id.'&numero='.$this->numero);
  }
  public function getPersonne() {
    return '';
  }

  public function __toString() {
    $str = substr(strip_tags($this->expose), 0, 250);
    if (strlen($str) == 250) {
      $str .= '...';
    }
    return $str;
  }

  public function setAuteurs($auteurs) {
    $groupe = null;
    $sexe = null;
    if (preg_match('/^\s*(.*),+\s*[dl]es\s+(.*\s+[gG]roupe|membres|députés)\s+(.*)\s*$/' ,$auteurs, $match)) {
      $auteurs = $match[1];
      $groupe = preg_replace("/^\s*(de la|de l'|du)\s*/", "", $match[3]);
      if (preg_match('/^(.*)(et|,)\s+(M[\s\.ml].*)$/' ,$groupe, $match2)) {
        $groupe = $match2[1];
        $auteurs .= ", ".$match2[3];
      }
      $tmpgroupe = null;
      foreach (myTools::getGroupesInfos() as $gpe)
        if (preg_match('/('.$gpe[4].'|'.$gpe[1].')/i', $groupe)) $tmpgroupe = $gpe[1];
      if ($tmpgroupe) $groupe = $tmpgroupe;
      else $groupe = null;
    }
    if ($debug) echo $auteurs." // ".$groupe."\n";
    $arr = preg_split('/,/', $auteurs);
    $signataireindex = 1;
    foreach ($arr as $depute) {
      if (preg_match('/^(.*)\((.*)\)/', $depute, $match)) {
        $depute = trim($match[1]);
        $circo = preg_replace('/\s/', '-', ucfirst(trim($match[2])));
      } else $circo = null;
      if (preg_match('/(gouvernement|président|rapporteur|commission|questeur)/i', $depute)) {
        if ($debug) print "WARN: Skip auteur ".$depute." for ".$this->source."\n";
        continue;
      } elseif (preg_match('/^\s*(M+[\s\.ml]{1})[a-z]*\s*([a-zA-Z].*)\s*$/', $depute, $match)) {
          $nom = $match[2];
          if (preg_match('/M[ml]/', $match[1]))
            $sexe = 'F';
          else $sexe = 'H';
      } else $nom = preg_replace("/^\s*(.*)\s*$/", "\\1", $depute);
      $nom = ucfirst($nom);
      if ($debug) echo $nom."//".$sexe."//".$groupe."//".$circo." => ";
      $depute = Doctrine::getTable('Parlementaire')->findOneByNomSexeGroupeCirco($nom, $sexe, $groupe, $circo, $this);
      if (!$depute) print "ERROR: Auteur introuvable in ".$this->source."/".$this->numero." : ".$nom." // ".$sexe." // ".$groupe."\n";
      else {
        if ($debug) echo $depute->nom."\n";
        if (!$groupe && $depute->groupe_acronyme != "") $groupe = $depute->groupe_acronyme;
        $this->addParlementaire($depute, $signataireindex);
        $depute->free();
      }
      $signataireindex++;
    }
  }

  public function addParlementaire($depute, $signataireindex) {
    foreach(Doctrine::getTable('ParlementaireAmendement')->createQuery('pa')->select('parlementaire_id')->where('amendement_id = ?', $this->id)->fetchArray() as $parlamdt) if ($parlamdt['parlementaire_id'] == $depute->id) return true;
    
    $pa = new ParlementaireAmendement();
    $pa->_set('Parlementaire', $depute);
    $pa->_set('Amendement', $this);
    $pa->numero_signataire = $signataireindex;
    if ($pa->save()) {
      $pa->free();
      return true;
    } else return false;
  }

  public function getSignataires($link = 0) {
    $signa = preg_replace("/M\s+/", "M. ", $this->_get('signataires'));
    if ($link && !preg_match('/gouvernement/i',$signa))
      $signa = preg_replace('/(M+[\.mles\s]+)?([\wàéëêèïîôöûüÉ\s-]+)\s*(,\s*|$)/', '<a href="/deputes?search=\\2">\\1\\2</a>\\3', $signa);
    return $signa;
  }

  public function getSection() {
    return PluginTagTable::getObjectTaggedWithQuery('Section', array('loi:numero='.$this->texteloi_id))->fetchOne();
  }

  public function getIntervention($num_admt) {
    $query = PluginTagTable::getObjectTaggedWithQuery('Intervention', array('loi:numero='.$this->texteloi_id, 'loi:amendement='.$num_admt));
    $query->select('Intervention.id, Intervention.date, Intervention.seance_id, Intervention.md5')
      ->groupBy('Intervention.date')
      ->orderBy('Intervention.date DESC, Intervention.timestamp ASC');
    return $query->fetchOne();
  }

  public function getTitre($link = 0) {
    return $this->getPresentTitre($link).' au texte N° '.$this->texteloi_id.' - '.$this->sujet.' ('.$this->getPresentSort().')';
  }

  public function getShortTitre($link = 0) {
    return $this->getPresentTitre($link).' ('.$this->getPresentSort().')';
  }

  public function getPresentTitre($link = 0) {
    $parent = 0;
    $pluriel = "";
    $parent = $this->getTags(array('is_triple' => true,
	  'namespace' => 'loi',
	  'key' => 'sous_amendement_de',
	  'return'    => 'value'));
    if (count($parent) == 1)
      $titre = "Sous-Amendement";
    else {
      $parent = "";
      $titre = "Amendement";
    }
    $numeros = $this->numero;
    $lettre = $this->getLettreLoi();
    $ident = $this->getTags(array('is_triple' => true,
	  'namespace' => 'loi',
	  'key' => 'amendement',
	  'return'    => 'value'));
    if (count($ident) > 1 && $lettre != "") {
      sort($ident);
      if ($lettre) foreach ($ident as $iden) $iden .= $lettre;
      $numeros = implode(', ', $ident);
      $pluriel = "s";
    }
    $titre .= $pluriel." N° ".$numeros;
    if ($this->rectif == 1)
      $titre .= " rectifié".$pluriel;
    elseif($this->rectif > 1)
      $titre .= " ".$this->rectif."ème rectif.";
    if ($parent != 0) {
      $titre .= ' à ';
      if ($link && function_exists('url_for')) {
	$titre .= '<a href="'.url_for('@amendement?loi='.$this->texteloi_id.'&numero='.$parent[0]).'">';
      }else{
	$link = 0;
      }
      $titre .= 'l\'amendement N° '.$parent[0].$lettre;
      if ($link) $titre .= '</a>';
    }
    return $titre;
  }

  public function getPresentSort() {
    return preg_replace('/indéfini/i', 'Sort indéfini', $this->getSort());
  }

  public function getTexte($style=1) {
    if ($style == 1) {
      return preg_replace('/\<p\>\s*«\s*([^\<]+)\<\/p\>/', '<blockquote>«&nbsp;\1</blockquote>', $this->_get('texte')); 
    } else return $this->_get('texte');
  }

  public function getLettreLoi() {
    if (preg_match('/^([A-Z])\d/', $this->numero, $match)) {
      return $match[1];
    }
    return;
  }

  public function getTitreNoLink() {
    return preg_replace('/\<a href.*\>(.*)<\/a\>/', '\1', $this->getTitre());
  }
  
  public function getLinkPDF() {
    return preg_replace('/\/amendement/', '/pdf/amendement', preg_replace('/\.asp(.*)$/', '.pdf', $this->source));
  }

  public function getIsLastVersion() {
    if ($this->sort === "Rectifié")
      return false;
    return true;
  }

}
