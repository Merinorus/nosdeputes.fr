<h1>Les sénateurs par circonscription</h1>
<div id="carte_circo">
<h2><?php echo $circo.(preg_match('/[eétranger]/i', $circo) ? "" : " (".Parlementaire::getNumeroDepartement($circo).")"); ?></h2>
<?php $sf_response->setTitle($circo.' ('.$departement_num.') : Les sénateurs par circonscription'); ?>
<?php // include_partial('map', array('num'=>strtolower($departement_num), 'size' => 400)); ?>
<p><?php echo $total; ?> sénateurs trouvés :</p>
<div class="list_table">
  <?php include_partial('parlementaire/table', array('senateurs' => $parlementaires, 'list' => 1)); ?>
</div>
</div>
