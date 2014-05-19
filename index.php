HOLLA!

<?php
// Usage without mysql_list_dbs()
$link = mysql_connect('localhost', 'root', 'root');
$res = mysql_query("SHOW DATABASES");

while ($row = mysql_fetch_assoc($res)) {
    echo $row['Database'] . "\n";
}
?>

<?php

phpinfo();

?>

