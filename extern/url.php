<?php
include './extern.inc';

$config = CRM_Core_Config::singleton();

// to keep backward compatibility for URLs generated
// by CiviCRM < 1.7, we check for the q variable as well
if (isset($_GET['qid'])) {
  $queue_id = CRM_Utils_Array::value( 'qid', $_GET );
}
else {
  $queue_id = CRM_Utils_Array::value( 'q', $_GET );
}
$url_id = CRM_Utils_Array::value( 'u', $_GET );

if ( ! $queue_id || ! $url_id ) {
  echo "Missing input parameters\n";
  exit( );
}

$url = CRM_Mailing_Event_BAO_TrackableURLOpen::track($queue_id, $url_id);

// CRM-7103
// looking for additional query variables and append them when redirecting
$query_param = $_GET;
unset($query_param['q'], $query_param['qid'], $query_param['u']);
$query_string = http_build_query($query_param);

if(stristr($url, '?')) {
	$url .= '&'. $query_string;
}
else {
	$url .= '?'. $query_string;
}

CRM_Utils_System::redirect($url);

