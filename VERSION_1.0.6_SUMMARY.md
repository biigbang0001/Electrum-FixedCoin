# ✅ Version 1.0.6 - Détection des Installations Existantes

## 🎯 Problème Résolu

Vous avez signalé avoir **déjà une installation d'ElectrumX** avec la mauvaise version, et vous vouliez que le script :
1. Détecte l'installation existante
2. Liste tous les fichiers et programmes
3. Propose des options (supprimer, garder, mettre à niveau)

## ✅ Solution Ajoutée

Le script **détecte automatiquement** les installations existantes au démarrage et propose **4 options** :

### Option 1 : Supprimer et Réinstaller
- Supprime tout
- Installation fraîche
- ⚠️ Nécessite ré-indexation

### Option 2 : Garder et Quitter
- Rien ne change
- Le script s'arrête

### Option 3 : Instance Additionnelle
- Non supporté automatiquement
- Pour utilisateurs avancés

### Option 4 : Mise à Niveau vers KomodoPlatform ⭐
- **C'EST CELLE QU'IL VOUS FAUT !**
- Change seulement le code source
- **Préserve la base de données**
- Pas besoin de ré-indexer
- ~2-3 minutes

---

## 🔍 Ce Que le Script Détecte

```
✓ Systemd service: electrumx.service
  Status: RUNNING

✓ User: electrumx

✓ Data directory: /var/electrum
  Database size: 2.5G
  Configuration: Present

✓ Virtual environment: /home/electrumx/electrumx-venv
  Binary: Present

✓ Source directory: /home/electrumx/electrumx-source
  Repository: spesmilo/electrumx (old version)
  Branch: 1.16.0
```

---

## 🚀 Comment Mettre à Niveau (Dans Votre Cas)

### 1. Télécharger le Nouveau Script v1.0.6
```bash
# Les fichiers sont dans /mnt/user-data/outputs/
```

### 2. Lancer le Script
```bash
chmod +x install_electrumx_fixedcoin.sh
sudo ./install_electrumx_fixedcoin.sh
```

### 3. Le Script Détecte Votre Installation
```
⚠️  Notice: You have the old spesmilo version installed.
   This script will install the KomodoPlatform version (better for altcoins).
```

### 4. Choisir l'Option 4
```
Your choice [1/2/3/4]: 4
```

### 5. Attendre 2-3 Minutes
```
✅ Upgrade completed!

Your ElectrumX is now running the KomodoPlatform version.
Database and configuration have been preserved.
```

### 6. Vérifier
```bash
sudo systemctl status electrumx
sudo journalctl -u electrumx -f
```

---

## 📦 Fichiers Mis à Jour

### Fichiers Principaux

1. **[install_electrumx_fixedcoin.sh](computer:///mnt/user-data/outputs/install_electrumx_fixedcoin.sh)** ⭐
   - Version 1.0.6
   - Détection automatique
   - 3 nouvelles fonctions :
     * `detect_existing_installation()`
     * `remove_existing_installation()`
     * `upgrade_to_komodo()`

2. **[CHANGELOG.md](computer:///mnt/user-data/outputs/CHANGELOG.md)**
   - Ajout de la version 1.0.6
   - Documentation des nouvelles fonctionnalités

3. **[DETECTION_FEATURE_FR.md](computer:///mnt/user-data/outputs/DETECTION_FEATURE_FR.md)** 🆕
   - Documentation complète en français
   - Explication détaillée des 4 options
   - Scénarios d'utilisation

---

## ✨ Avantages

### Sécurité
- ✅ Détection avant toute modification
- ✅ Confirmation requise pour suppression
- ✅ Sauvegarde automatique du code source

### Flexibilité
- ✅ 4 options pour tous les besoins
- ✅ Mise à niveau sans perte de données
- ✅ Option de réinstallation propre

### Information
- ✅ Affichage clair de ce qui est détecté
- ✅ Identification du type de repository (spesmilo vs KomodoPlatform)
- ✅ Taille de la base de données
- ✅ Statut du service

---

## 🎯 Ce Qui Est Préservé (Option 4)

Avec l'option 4 (mise à niveau), ces éléments sont **préservés** :

- ✅ Base de données complète (`/var/electrum/db/`)
- ✅ Configuration (`/var/electrum/electrumx.conf`)
- ✅ Certificats SSL (`/var/electrum/ssl/`)
- ✅ Logs (`/var/electrum/logs/`)
- ✅ Banner personnalisé
- ✅ Service systemd
- ✅ Utilisateur et permissions

**Seul le code source est remplacé** : spesmilo → KomodoPlatform

---

## ⚠️ Important

### Option 4 vs Option 1

| Critère | Option 4 (Upgrade) | Option 1 (Remove + Install) |
|---------|-------------------|----------------------------|
| Temps | 2-3 minutes | 5-10 min + plusieurs heures |
| Base de données | ✅ Préservée | ❌ Supprimée |
| Ré-indexation | ❌ Non nécessaire | ✅ Nécessaire |
| Configuration | ✅ Préservée | ❌ Recréée |
| SSL | ✅ Préservé | ❌ Régénéré |
| Recommandé pour | Mise à niveau | Installation corrompue |

**Dans votre cas** : Choisissez l'**Option 4** !

---

## 📝 Checklist Rapide

Avant de lancer :
- [ ] Télécharger le script v1.0.6
- [ ] Avoir accès sudo

Pendant l'exécution :
- [ ] Choisir l'option 4
- [ ] Attendre 2-3 minutes

Après la mise à niveau :
- [ ] Vérifier : `sudo systemctl status electrumx`
- [ ] Logs : `sudo journalctl -u electrumx -f`
- [ ] Test : `echo '{"id": 1, "method": "server.version"}' | nc localhost 50001`

---

## 🎉 Résumé en 3 Points

1. **Nouveau** : Le script détecte maintenant les installations existantes
2. **4 Options** : Supprimer, Garder, Multiple, ou Mettre à niveau
3. **Votre Solution** : Option 4 = Upgrade vers KomodoPlatform en 2 minutes sans perdre de données

---

**Version** : 1.0.6  
**Date** : 28 octobre 2025  
**Status** : ✅ Prêt à Utiliser  

**Votre problème est résolu ! 🚀**
