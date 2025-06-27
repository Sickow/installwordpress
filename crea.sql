mysql -uroot -pexamplerootPW -e "CREATE DATABASE wordpress;" 
mysql -uroot -pexamplerootPW -e "CREATE USER 'example'@'localhost' 
IDENTIFIED BY 'examplePW';" 
mysql -uroot -pexamplerootPW -e "GRANT ALL PRIVILEGES ON wordpress.* TO 
'example'@'localhost';" 
mysql -uroot -pexamplerootPW -e "FLUSH PRIVILEGES;" 
