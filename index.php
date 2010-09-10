<?php
/**
 * Front to the WordPress application. This file doesn't do anything, but loads
 * wp-blog-header.php which does and tells WordPress to load the theme.
 *
 * @package WordPress
 */

/**
 * Tells WordPress to load the WordPress theme and output it.
 *
 * @var bool
 */
define('WP_USE_THEMES', false);

/** Loads the WordPress Environment and Template */
require('.././wp-blog-header.php');

global $wpdb; 
$table_name = $wpdb->prefix . "questions";

//::::::::  UPLOADS :::::::: handle new file submissions
///////////////////////////////////////////////////////////
if (isset($_REQUEST["user"]) && isset($_FILES['datafile']['tmp_name']))
{
           
  // filename is valid ?  File is valid type ?
  $allowedExtensions = array("wav","mp3","caf");

  foreach ($_FILES as $file) { 
    if ($file['tmp_name'] > '') { 
      if (!in_array(end(explode(".", 
            strtolower($file['name']))), 
            $allowedExtensions)) { 
       die($file['name'].' is an invalid file type!<br/>'. 
        '<a href="javascript:history.go(-1);">'. 
        '&lt;&lt Go Back</a>'); 
      } 
    } 
  }

  $userName = $_REQUEST["user"];
  
  $fileName = "{$_FILES['datafile'] ['name']}";
  move_uploaded_file ($_FILES['datafile'] ['tmp_name'], 
	"questions/{$_FILES['datafile'] ['name']}");
  $questionOrQuestionSet = $_REQUEST["questionOrQuestionSet"];

  
  // Now ... if it's an answer, insert a new SQL record
  if ($_REQUEST["isAnswer"])
  {
  	  $wpdb->update($table_name, array('answer' => $fileName),  array( 'ID' => $questionOrQuestionSet));
  }
  else // this is a new question ...
  {
  	  $wpdb->insert( $table_name, array( 'time' => current_time('mysql'), 
  	  	  'owner' => $userName,
  	  	  'path' => $fileName,
  	  	  'questionSet' => $questionOrQuestionSet
  	  	  ));
  }
  
}


// :::::: VIEW NEW Q/A :::::::::: generate XML for IPHONE
///////////////////////////////////////////////////////////////////////////
if ($_REQUEST['viewNew'])
{
//	var_dump($_REQUEST["lastUpdate"]);
//	2010-08-31
	// query the DB and get new questions ... 
	$sql = "SELECT * FROM " . $table_name." WHERE updated > '".$_REQUEST["lastUpdate"]."' AND owner = ".$_REQUEST["user"];
	
 	$soundbites = $wpdb->get_results($sql);
	
 	header("Content-Type:text/xml; charset=iso-8859-1");
	
 	//Creates XML string and XML document using the DOM 
 	$dom = new DomDocument('1.0'); 
 	$userXML = $dom->appendChild($dom->createElement('user')); 
 
 	foreach($soundbites as $soundbite)
 	{ 	 
		$question = $userXML->appendChild($dom->createElement('question')); 
		$question->setAttribute('id',  $soundbite->id);
		$question->setAttribute('name', $soundbite->path);
		$question->setAttribute('questionSet', $soundbite->questionSet);
		$question->setAttribute('answer', $soundbite->answer);
		$question->setAttribute('comments', $soundbite->comments);
	}
	
	
	// and a timestamp ..... for tracking ...
 	$updated = $userXML->appendChild($dom->createElement('updatedTime')); 
 	$timestamp = date("Y-m-d G:i:s");
 	$updated->setAttribute('time', $timestamp );
	
              
	//generate xml 
	$dom->formatOutput = true; // set the formatOutput attribute of 
       
	// save XML as string or file 
	//$test1 = $dom->saveXML(); // put string in test1 
	//$dom->save('test10.xml'); // save as file 
 
	echo $dom->saveXML();
	die;

}
else // HTML document header 
{
	?>
		<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
		<html>
		<head>
		   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		   <title>Soundbite Manager App</title> 
		</head>
	<?php
}


// :::::: CONFIRMATIONS ::::: handle a message that indicates this question has been downloaded successfully
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
if ($_REQUEST['questionNum'])
{
	// get that question ...
	$sql = "SELECT delivered FROM " . $table_name." WHERE id = ".$_REQUEST['questionNum'];
 	$results = $wpdb->get_results($sql);
	 
 	// toggle downloaded / not for now ..... 
 	$switch = FALSE;
 	if ($results[0]->delivered == 0)
 	{
 		$switch = TRUE;
 	}
 
	$wpdb->update($table_name, array( 'delivered' => $switch),  array( 'ID' => $_REQUEST['questionNum']));

}


   
// ::::: LIST QUESTIONS :::::::::: display a table of all questions
//////////////////////////////////////////////////////////////////////////////////////////////
 
echo '<div style="width:400px; position:relative; left:100px; background:white; padding:30px; font-color:black;">';

// create a table (if not present already) to store the question list ...
 if($wpdb->get_var("SHOW TABLES LIKE '$table_name'") != $table_name) 
 { 
 	 echo "no table in SQL!";
 	 
 	 // this is the schema ....
 	 // it is not accurate, as I have made changes through PHPAdmin
 	 $sql = "CREATE TABLE " . $table_name . " (
	  id mediumint	(9) NOT NULL AUTO_INCREMENT,
	  time bigint(11) DEFAULT '0' NOT NULL,
	  owner tinytext NOT NULL,
	  questionSet text NOT NULL,
	  questionPath text NOT NULL,
	  answerPath text NOT NULL,
	  UNIQUE KEY id (id)
	);";
	
	require_once(ABSPATH . 'wp-admin/includes/upgrade.php');
	dbDelta($sql); 	 
}
else
{
 	 
 	$sql = "SELECT * FROM " . $table_name." WHERE owner = ".$_REQUEST["user"];
 	$results = $wpdb->get_results($sql);
	 
	echo "User: ".$_REQUEST["user"];
	echo "<br/>Number of Questions: ".count($results);
	 
		
	echo "<ol style='margin-left:20px;'>";
	foreach($results as $result)
	{
		?>
		
		<li style="width:100%; height:50px;"> 
		
		<p style="display:inline;"> 
		<?php if( ! $result->delivered)
		{
			echo '<span style="color:blue;"> new! </span>';
		}
		?>
		question - <?php echo $result->questionPath ?></p>
			<form method='post' enctype="multipart/form-data">
			<input name='user' type='hidden' value='1'>
			<input name='questionNum' type='hidden' value="<?php echo $result->id; ?>"> 
			<input type="submit" name="submit" style="float:right;" value="got it!">
			</form>

		</li>
		<li>
		 	<?php echo $result->updated; ?>
		</li>
		<?php
	}
	echo"</ol>";
}
 


// render the HTML FORM for uploading new soundbites
///////////////////////////////////////////////////////////
?>

<br/>
<br/>
Upload a new Question:
<br/>

<form method='post' enctype="multipart/form-data">

user<input name='user' type='text' value='1'> </br>
question set<input name='questionOrQuestionSet' type='text' value='1'></br>

<input type="file" name="datafile" size="40">

<br/>
<input type="submit" name="mysubmit" value="Add New File">

</form>




</div>

<?php

die;

?>