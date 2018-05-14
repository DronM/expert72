
<!DOCTYPE html>
<html>
<body>

<form action="1.php" method="post" enctype="multipart/form-data">
	<input type="text" name="field1" id="field1">
	<input type="text" name="field2" id="field2">
    Select image to upload:
    <input type="file" name="fileToUpload" id="fileToUpload">
    <input type="submit" value="Upload Image" name="submit">
</form>

</body>
</html>

<?php
var_dump($_REQUEST);
?>
