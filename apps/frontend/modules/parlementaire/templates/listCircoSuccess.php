<p><? echo $circo; ?> : <? $nResults = $pager->getNbResults(); echo $nResults; ?> député<? if ($nResults > 1) echo 's'; ?></p>
<ul>
<? foreach($pager->getResults() as $parlementaire) : ?>
<li><? echo $parlementaire->getNumCircoString(); ?> : <? echo link_to($parlementaire->nom, 'parlementaire/show?slug='.$parlementaire->slug); ?> (<? echo $parlementaire->getStatut(); ?> <? echo link_to($parlementaire->getGroupe()->getNom(), '@list_parlementaires_organisme?slug='.$parlementaire->getGroupe()->getSlug()); ?>)</li>
<? endforeach ; ?>
</ul>
<? if ($pager->haveToPaginate()) : ?>
<div class="pagination">
    <a href="<?php echo url_for('parlementaire/list') ?>?nom_circo=<? echo $circo; ?>&page=1">
   << 
    </a>
 
    <a href="<?php echo url_for('parlementaire/list') ?>?nom_circo=<? echo $circo; ?>&page=<?php echo $pager->getPreviousPage() ?>">
   <
    </a>
 
    <?php foreach ($pager->getLinks() as $page): ?>
      <?php if ($page == $pager->getPage()): ?>
        <?php echo $page ?>
      <?php else: ?>
        <a href="<?php echo url_for('parlementaire/list') ?>?nom_circo=<? echo $circo; ?>&page=<?php echo $page ?>"><?php echo $page ?></a>
      <?php endif; ?>
    <?php endforeach; ?>
 
    <a href="<?php echo url_for('parlementaire/list') ?>?nom_circo=<? echo $circo; ?>&page=<?php echo $pager->getNextPage() ?>">
   >
    </a>
 
    <a href="<?php echo url_for('parlementaire/list') ?>?nom_circo=<? echo $circo; ?>&page=<?php echo $pager->getLastPage() ?>">
   >>
    </a>
</div>
<? endif; ?>