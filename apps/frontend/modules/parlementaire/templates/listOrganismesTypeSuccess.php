<h1>Liste des <?php echo $human_type; ?></h1>
<p>
<ul>
<?php foreach($organismes as $o) : ?>
<li><a href="<?php echo url_for('@list_parlementaires_organisme?slug='. $o->slug); ?>"><?php echo $o->nom; ?></a></li>
<?php endforeach; ?>
</ul>
</p>
<p><a href="<?php echo url_for('@list_organismes'); ?>">Retour à la liste des types d'organismes</a></p>
