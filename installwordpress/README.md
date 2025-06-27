# Rôle Ansible : installwordpress

## 🚀 Objectif

Ce rôle Ansible permet de déployer automatiquement un site WordPress avec une base de données MariaDB sur des serveurs Ubuntu **ou** Rocky Linux, dans un environnement **conteneurisé**. Il est conçu pour être **idempotent**, **réutilisable** et **publiable sur Ansible Galaxy**.

---

## 🌐 Compatibilités

* Ubuntu >= 20.04
* Rocky Linux >= 8.0

---

## 🔧 Tâches principales

1. Mise à jour des paquets
2. Installation des dépendances pour Apache, MariaDB et PHP
3. Démarrage de MariaDB (sans `systemd`, avec `mysqld_safe`)
4. Initialisation de la base de données WordPress
5. Installation de WordPress dans `/var/www/html`
6. Configuration d'Apache : activation de site, rewrite, configuration spécifique Ubuntu/Rocky
7. Lancement du service PHP-FPM sur Rocky Linux (avec fix du bug `/run/php-fpm`)

---

## 📂 Structure du rôle

```
installwordpress/
├── defaults/
│   └── main.yml
├── files/
│   ├── wordpress.conf              # Apache conf pour Ubuntu
│   └── wordpress_rocky.conf        # Apache conf pour Rocky Linux
├── handlers/
│   └── main.yml
├── tasks/
│   └── main.yml
├── templates/
│   └── wp-config.php.j2
├── vars/
│   └── main.yml
├── README.md
```

---

## 📊 Variables principales

Définies dans `defaults/main.yml` ou surchargées dans votre playbook :

```yaml
db_name: wordpress
wordpress_url: https://wordpress.org/latest.tar.gz
wordpress_site_dir: /var/www/html
apache_user: apache
```

Variables à **personnaliser en sécurité** :

```yaml
db_root_password: root_pass
db_user: wp_user
db_password: wp_pass
```

---

## 🚨 Particularités techniques

### MariaDB

* Démarrage sans `systemd` via :

  ```bash
  nohup mysqld_safe --user=mysql &
  ```
* Initialisation automatique si `/var/lib/mysql/mysql` absent

### Apache

* Ubuntu : `service apache2 start`
* Rocky : `nohup /usr/sbin/httpd -DFOREGROUND &`

### PHP-FPM (Rocky)

* Lance `php-fpm` manuellement (car pas de `systemctl`) :

  ```bash
  mkdir -p /run/php-fpm
  nohup php-fpm --fpm-config /etc/php-fpm.conf &
  ```
* Le rôle attend la création de `/run/php-fpm/www.sock`

---

## 📕 Exemple de playbook d'appel

```yaml
- name: Déploiement WordPress
  hosts: all
  become: true
  vars:
    db_name: wordpress
    db_user: wp_user
    db_password: wp_pass
    db_root_password: root_pass
  roles:
    - installwordpress
```

---

## ▶️ Comment l'exécuter correctement

Voici les étapes recommandées pour exécuter proprement le rôle dans votre environnement Docker :

1. Démarrer les conteneurs (Ubuntu et Rocky) avec les bons ports mappés (`80`, `22`, etc.)
2. Vérifier que vos inventaires pointent bien sur les conteneurs actifs
3. Exécuter le playbook de test avec :

   ```bash
   ansible-playbook -i inventory.ini playbook.yml
   ```
4. Attendre que tous les services soient initialisés (base + apache + php-fpm)
5. Accéder à WordPress via :

   * [http://localhost:8083](http://localhost:8083) (Ubuntu 1)
   * [http://localhost:8084](http://localhost:8084) (Ubuntu 2)
   * [http://localhost:8085](http://localhost:8085) (Rocky 1)
   * [http://localhost:8086](http://localhost:8086) (Rocky 2)

---

## 🛠️ Contenus SQL fournis

Le projet comprend deux scripts SQL utiles pour initialiser manuellement ou valider les étapes de base de données.

### `secure.sql`

```sql
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'examplerootPW';"
mysql -uroot -pexamplerootPW -e "DELETE FROM mysql.user WHERE User='';"
mysql -uroot -pexamplerootPW -e "DROP DATABASE IF EXISTS test;"
mysql -uroot -pexamplerootPW -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
mysql -uroot -pexamplerootPW -e "FLUSH PRIVILEGES;"
```

### `crea.sql`

```sql
mysql -uroot -pexamplerootPW -e "CREATE DATABASE wordpress;"
mysql -uroot -pexamplerootPW -e "CREATE USER 'example'@'localhost' IDENTIFIED BY 'examplePW';"
mysql -uroot -pexamplerootPW -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'example'@'localhost';"
mysql -uroot -pexamplerootPW -e "FLUSH PRIVILEGES;"
```

Ces fichiers sont situés **en dehors du rôle**, à la racine du projet.

---

## 📅 Auteur

Sickow

---

## 🔧 Environnement de test

| Conteneur | Image Docker                | Ports | Fonctionnel ?            |
| --------- | --------------------------- | ----- | ------------------------ |
| Ubuntu 1  | `ftutorials/ubuntu-ssh:1.0` | 8083  | Oui ✅                    |
| Ubuntu 2  | `ftutorials/ubuntu-ssh:1.0` | 8084  | Oui ✅                    |
| Rocky 1   | `ftutorials/rocky-ssh:1.0`  | 8085  | Oui ✅ (avec fix php-fpm) |
| Rocky 2   | `ftutorials/rocky-ssh:1.0`  | 8086  | Oui ✅ (avec fix php-fpm) |
