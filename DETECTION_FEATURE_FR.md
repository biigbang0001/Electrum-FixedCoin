# 🎯 Nouvelle Fonctionnalité v1.0.6 - Détection et Gestion des Installations

## ✅ Votre Demande

Vous aviez déjà une ancienne version d'ElectrumX installée et vous vouliez :
1. Que le script détecte automatiquement l'installation existante
2. Voir tous les fichiers et programmes ElectrumX en place
3. Choisir entre supprimer l'ancienne installation ou en installer une nouvelle

## 🎉 Solution Implémentée

J'ai ajouté une **détection automatique complète** qui s'exécute au début du script.

---

## 🔍 Ce Que Détecte le Script

Le script scanne automatiquement votre système et détecte :

### 1. Service Systemd
```
✓ Systemd service: electrumx.service
  Status: RUNNING / STOPPED
```

### 2. Utilisateur
```
✓ User: electrumx
```

### 3. Répertoires de Données
```
✓ Data directory: /var/electrum
  Database size: 2.5G
  Configuration: Present
```

### 4. Environnement Virtuel Python
```
✓ Virtual environment: /home/electrumx/electrumx-venv
  Binary: Present
```

### 5. Code Source et Type de Repository
```
✓ Source directory: /home/electrumx/electrumx-source
  Repository: KomodoPlatform/electrumx-1 ✅
  ou
  Repository: spesmilo/electrumx (old version)
  Branch: master
```

### 6. Anciennes Installations
```
✓ Old installation: ~/.local/bin/electrumx_server
  Note: This is from v1.0.1-1.0.2 (--user method)
```

---

## 🎛️ Menu Interactif - 4 Options

Quand une installation existante est détectée, vous voyez ce menu :

```
╔══════════════════════════════════════════════════════════════╗
║                    What do you want to do?                   ║
╚══════════════════════════════════════════════════════════════╝

  [1] Remove existing installation and install fresh
      (Recommended if upgrading from spesmilo to KomodoPlatform)

  [2] Keep existing installation and exit
      (Use this if you want to keep your current setup)

  [3] Install additional instance (advanced)
      (Not recommended - requires manual configuration)

  [4] Upgrade to KomodoPlatform version (keep data)
      (Only changes source code, preserves database and config)

Your choice [1/2/3/4]: 
```

---

## 📋 Détails des 4 Options

### Option 1 : Supprimer et Réinstaller
**Quand l'utiliser ?**
- Vous voulez repartir de zéro
- Vous avez des problèmes avec l'installation actuelle
- Vous voulez une installation propre

**Ce qui sera supprimé :**
- ✓ Service systemd
- ✓ Utilisateur electrumx
- ✓ Toutes les données dans /var/electrum (base de données incluse)
- ✓ Environnement virtuel Python
- ✓ Code source

**Sécurité :**
Le script demande une confirmation avec le mot "yes" pour éviter les suppressions accidentelles.

---

### Option 2 : Garder et Quitter
**Quand l'utiliser ?**
- Votre installation actuelle fonctionne bien
- Vous ne voulez rien changer
- Vous avez lancé le script par erreur

**Ce qui se passe :**
Le script s'arrête immédiatement sans rien modifier.

---

### Option 3 : Instance Additionnelle
**Quand l'utiliser ?**
- Vous êtes un utilisateur avancé
- Vous voulez plusieurs serveurs ElectrumX sur la même machine

**Important :**
Cette option n'est PAS supportée automatiquement. Le script affiche un message expliquant qu'il faut :
- Utiliser des noms d'utilisateurs différents
- Utiliser des ports différents
- Utiliser des répertoires différents

Puis le script s'arrête.

---

### Option 4 : Mise à Niveau vers KomodoPlatform
**Quand l'utiliser ?**
- ⭐ **C'EST VOTRE CAS !**
- Vous avez l'ancienne version (spesmilo)
- Vous voulez passer à KomodoPlatform
- Vous voulez **GARDER votre base de données** (pas besoin de ré-indexer)

**Ce qui est fait automatiquement :**

1. **Arrêt du service**
   ```bash
   sudo systemctl stop electrumx
   ```

2. **Sauvegarde du code source actuel**
   ```
   Backup: /home/electrumx/electrumx-source.backup-1730123456
   ```

3. **Clone du nouveau repository**
   ```bash
   git clone https://github.com/KomodoPlatform/electrumx-1.git
   ```

4. **Réinstallation dans le venv existant**
   ```bash
   pip install -e .
   ```

5. **Redémarrage du service**
   ```bash
   sudo systemctl start electrumx
   ```

**CE QUI EST PRÉSERVÉ :**
- ✅ Base de données complète (/var/electrum/db/)
- ✅ Configuration (/var/electrum/electrumx.conf)
- ✅ Certificats SSL (/var/electrum/ssl/)
- ✅ Logs (/var/electrum/logs/)
- ✅ Banner personnalisé

**Résultat :**
Votre serveur continue de fonctionner exactement comme avant, mais avec le code KomodoPlatform qui est meilleur pour les altcoins comme FixedCoin.

---

## 🎯 Scénarios d'Utilisation

### Scénario 1 : Première Installation (Serveur Propre)
```
✓ No existing ElectrumX installation detected

→ Le script continue normalement
→ Installation complète automatique
```

### Scénario 2 : Vous Avez la Vieille Version (spesmilo)
```
⚠️  Notice: You have the old spesmilo version installed.

Your choice [1/2/3/4]: 4

→ Mise à niveau automatique vers KomodoPlatform
→ Données préservées
→ Service redémarré
✅ Terminé en 2 minutes
```

### Scénario 3 : Vous Avez Déjà KomodoPlatform
```
✅ Good news! You already have the KomodoPlatform version installed.

Your choice [1/2/3/4]: 2

→ Le script s'arrête
→ Rien n'est modifié
```

### Scénario 4 : Vous Voulez Tout Recommencer
```
Your choice [1/2/3/4]: 1

Are you ABSOLUTELY SURE? (type 'yes' to confirm): yes

→ Suppression complète
→ Installation fraîche
→ Nouvelle base de données (nécessite ré-indexation)
```

---

## 📊 Informations Affichées

Le script vous montre exactement ce qu'il trouve :

```
════════════════════════════════════════════════════════════════
⚠  Existing ElectrumX installation detected!

Components found: 5

⚠️  Notice: You have the old spesmilo version installed.
   This script will install the KomodoPlatform version (better for altcoins).

╔══════════════════════════════════════════════════════════════╗
║                    What do you want to do?                   ║
╚══════════════════════════════════════════════════════════════╝
```

---

## 🚀 Comment Utiliser (Dans Votre Cas)

### Étape 1 : Lancer le Script
```bash
sudo ./install_electrumx_fixedcoin.sh
```

### Étape 2 : Le Script Détecte Votre Installation
```
✓ Systemd service: electrumx.service
✓ User: electrumx
✓ Data directory: /var/electrum
  Database size: 2.5G
✓ Source directory: /home/electrumx/electrumx-source
  Repository: spesmilo/electrumx (old version)
```

### Étape 3 : Choisir l'Option 4
```
Your choice [1/2/3/4]: 4
```

### Étape 4 : Confirmation et Mise à Niveau
```
Upgrading to KomodoPlatform version...
Stopping electrumx service...
Backing up current source...
Cloning KomodoPlatform/electrumx-1...
Reinstalling in virtual environment...
Restarting electrumx service...

✅ Upgrade completed!

Your ElectrumX is now running the KomodoPlatform version.
Database and configuration have been preserved.
```

### Étape 5 : Vérification
```bash
# Vérifier le statut
sudo systemctl status electrumx

# Voir les logs
sudo journalctl -u electrumx -f
```

---

## ⚠️ Important à Savoir

### Pas Besoin de Ré-indexer !
Avec l'option 4, votre base de données est **préservée**. Vous n'avez **PAS besoin** de ré-indexer la blockchain FixedCoin. Le serveur redémarre et continue exactement là où il était.

### Sauvegarde Automatique
Le code source actuel est automatiquement sauvegardé dans :
```
/home/electrumx/electrumx-source.backup-[timestamp]
```

Si quelque chose ne va pas, vous pouvez restaurer :
```bash
sudo systemctl stop electrumx
sudo rm -rf /home/electrumx/electrumx-source
sudo mv /home/electrumx/electrumx-source.backup-XXXXX /home/electrumx/electrumx-source
sudo systemctl start electrumx
```

### Temps de Mise à Niveau
- Option 4 (upgrade) : ~2-3 minutes
- Option 1 (remove + install) : ~5-10 minutes + ré-indexation (plusieurs heures)

---

## 🎉 Avantages de Cette Fonctionnalité

### 1. Sécurité
- ✅ Détection avant modification
- ✅ Confirmation requise pour suppression
- ✅ Sauvegarde automatique

### 2. Flexibilité
- ✅ 4 options adaptées à différents besoins
- ✅ Mise à niveau sans perte de données
- ✅ Installation propre si nécessaire

### 3. Information
- ✅ Affichage clair de ce qui est détecté
- ✅ Identification du type de repository
- ✅ Taille de la base de données
- ✅ Statut du service

### 4. Simplicité
- ✅ Un seul script pour tout gérer
- ✅ Processus guidé étape par étape
- ✅ Messages clairs en anglais

---

## 📝 Notes Techniques

### Détection Multi-Niveaux
Le script vérifie :
1. Service systemd (systemctl)
2. Utilisateur système (id -u)
3. Répertoires de données (existence + taille)
4. Environnement virtuel Python
5. Repository Git (remote URL)
6. Installations anciennes (méthode --user)

### Gestion des Erreurs
- Arrêt propre si choix invalide
- Confirmation pour actions destructives
- Messages d'erreur clairs
- Retour d'état approprié

---

## ✅ Checklist de Mise à Niveau

Avant de lancer le script :
- [ ] Vous avez un backup de vos données (recommandé mais pas obligatoire)
- [ ] Le service FixedCoin fonctionne correctement
- [ ] Vous avez accès sudo sur le serveur

Pendant l'exécution :
- [ ] Choisir l'option 4 pour mise à niveau avec préservation des données
- [ ] Attendre la fin du processus (2-3 minutes)

Après la mise à niveau :
- [ ] Vérifier le statut : `sudo systemctl status electrumx`
- [ ] Vérifier les logs : `sudo journalctl -u electrumx -f`
- [ ] Vérifier la connexion : `echo '{"id": 1, "method": "server.version"}' | nc localhost 50001`

---

## 🎯 Résumé

**Version** : 1.0.6  
**Nouvelle Fonctionnalité** : Détection et gestion automatique des installations existantes  
**Votre Besoin** : Passer de spesmilo à KomodoPlatform sans perdre les données  
**Solution** : Option 4 - Upgrade to KomodoPlatform (keep data)  
**Temps** : ~2-3 minutes  
**Données Préservées** : ✅ Oui - Pas besoin de ré-indexer  

---

**Prêt à mettre à niveau ! 🚀**
