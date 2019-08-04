<?php if (!count($textes) || (count($textes) == 1 && preg_match('/questions?\s/', $textes[0]['Section']['titre']))) { ?>
    <i class="paddingleft"><?php echo $parlementaire->ceCette; ?> n'a pris la parole sur aucun dossier en hémicycle.</i>
<?php return ;} ?>
<ul>
<?php $ct = 0;
foreach($textes as $texte) {
  if (preg_match('/questions?\s/', $texte['Section']['titre']) || !preg_match('/[a-z]/', $texte['Section']['titre'])) continue;
  echo '<li>'.link_to(ucfirst(preg_replace('/\s*\?$/', '', $texte['Section']['titre'])).($texte['fonction'] ? (preg_match("/rapporteur/", $texte['fonction']) ? ", <b><i>".$texte['fonction']."</i></b>" : ", <i>".$texte['fonction']."</i>") : ""), '@parlementaire_texte?slug='.$parlementaire->slug.'&id='.$texte['section_id']).' (<span class="list_inter">'.$texte['nb'].'&nbsp;intervention'.($texte['nb'] > 1 ? 's' : '').'</span>)</li>';
  $ct++;
  if (isset($limit) && $ct == $limit)
    break;
} ?>
</ul>
<p class="suivant"><?php echo link_to('Tous ses dossiers', '@parlementaire_textes?slug='.$parlementaire->slug); ?></p>
