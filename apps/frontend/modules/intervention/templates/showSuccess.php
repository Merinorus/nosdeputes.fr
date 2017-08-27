<h1><?php echo $shorttitle; ?></h1>
<?php
$titre2 = link_to($seance->getTitre(0), '@interventions_seance?seance='.$seance->id.'#inter_'.$intervention->getMd5());
$titre2 .= ' <br/> ';
if (isset($orga))
  $titre2 .= link_to($orga->getNom(), '@list_parlementaires_organisme?slug='.$orga->getSlug());
if (isset($secparent))
  $titre2 .= link_to(ucfirst($secparent->getTitre()), '@section?id='.$section->section_id).'&nbsp;&mdash; ';
if ($section->getTitre())
  $titre2 .= link_to(ucfirst($section->getTitre()), '@section?id='.$section->id);
if(count($amdmts) >= 1)
  $titre2 .= ', amendement';
if(count($amdmts) > 1) $titre2 .= 's';
$titre2 .= ' ';
foreach($amdmts as $amdmt)
$titre2 .= link_to($amdmt, '@find_amendements_by_loi_and_numero?loi='.(implode(',',$lois).'&numero='.$amdmt)).' ';

?>
<h2><?php echo $titre2 ; ?></h2>
<div class="interventions">
  <?php echo include_component('intervention', 'parlementaireIntervention', array('intervention' => $intervention, 'complete' => true, 'lois' => $lois, 'amdmts' => $amdmts, 'section'=>$section)); ?>
</div>
