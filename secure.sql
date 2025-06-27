mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'examplerootPW';" 
mysql -uroot -pexamplerootPW -e "DELETE FROM mysql.user WHERE User='';" 
mysql -uroot -pexamplerootPW -e "DROP DATABASE IF EXISTS test;" 
mysql -uroot -pexamplerootPW -e "DELETE FROM mysql.db WHERE Db='test' OR 
Db='test\\_%';" 
mysql -uroot -pexamplerootPW -e "FLUSH PRIVILEGES;" 
