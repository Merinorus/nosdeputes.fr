<?php
if ($timefacet) {
	if (!isset($fdates))
		$exportfacet = null;
	else
		$exportfacet = $fdates;
}
if($parlfacet) {
	$exportfacet = null;
	if(isset($facet['parlementaires']))
		$exportfacet = $facet['parlementaires']['values'];
}
if ($tagsfacet) {
	$exportfacet = null;
	if (isset($facet['tag']))
		$exportfacet = $facet['tag']['values'];
}
if (isset($exportfacet)) {
	print(json_encode($exportfacet));
	return ;
}

if (!$tags) : ?>{"start": <?php echo $results['start'] + 1; ?>, "end": <?php if ($results['numFound'] == $results['end'] - 1) echo $results['end'] - 1; else echo $results['end']; ?>, "last_result": <?php echo $results['numFound'];  ?>, "results": [<?php
	    $nb = 0;
foreach ($results['docs'] as $record)
{
  if ($nb)
    echo ", ";
  else
    $nb = 1;
  echo '{"document_type": "'.get_class($record['object']).'"';
  echo ', "document_id": '.($record['object']->id ? $record['object']->id : '""')."";
  echo ', "document_url": "'.preg_replace('/([^:])\/\//', '\1/', sfConfig::get('app_base_url').url_for('@api_document?format='.$format.'&class='.get_class($record['object']).'&id='.$record['object']->id)).'"';
	echo ', "document_intervenant": "'.$record['personne'].'"';
	echo ', "document_content": "'. preg_replace('/^'.$record['personne'].' /', '', preg_replace('/<\/?em>/', '', $record['highlighting'])).'"';
	echo ', "document_date": "'.$record['date'].'"';
	echo '}';
}
?> ]}<?php return;
endif;
?>
[
<?php
    $cpt = 0;
foreach(array_keys($facet) as $k)
  if (isset($facet[$k]['values']) && count($facet[$k]['values']))
    foreach($facet[$k]['values'] as $value => $nb)
      if ($nb) {
	if ($cpt)
	  echo ", ";
	else
	  $cpt = 1;
	echo '{"tag_type": "'.$k.'", "tag_nom": "'.$value.'", "nb": '.$nb."}\n";
      } ?>
]
