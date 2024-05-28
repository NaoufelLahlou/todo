#!/bin/bash

# Fichier pour stocker les tâches
FICHIER_TACHES="taches_todo.txt"

# Fonction pour afficher les messages d'erreur sur stderr
erreur() {
    echo "$1" >&2
}

# Fonction pour créer une tâche
creer_tache() {
    read -p "Titre : " titre
    if [ -z "$titre" ]; then
        erreur "Le titre est requis."
        return 1
    fi
    read -p "Description : " description
    read -p "Lieu : " lieu
    read -p "Date d'échéance (AAAA-MM-JJ) : " date_echeance
    if [ -z "$date_echeance" ]; then
        erreur "La date d'échéance est requise."
        return 1
    fi
    read -p "Heure d'échéance (HH:MM) : " heure_echeance
    completion="non"
    
    id=$(($(wc -l < "$FICHIER_TACHES") + 1))
    
    echo "$id|$titre|$description|$lieu|$date_echeance $heure_echeance|$completion" >> "$FICHIER_TACHES"
    echo "Tâche créée avec l'ID $id."
}

# Fonction pour mettre à jour une tâche
mettre_a_jour_tache() {
    read -p "ID de la tâche à mettre à jour : " id
    if ! grep -q "^$id|" "$FICHIER_TACHES"; then
        erreur "ID de tâche non trouvé."
        return 1
    fi

    read -p "Nouveau Titre : " titre
    read -p "Nouvelle Description : " description
    read -p "Nouveau Lieu : " lieu
    read -p "Nouvelle Date d'échéance (AAAA-MM-JJ) : " date_echeance
    read -p "Nouvelle Heure d'échéance (HH:MM) : " heure_echeance
    read -p "Complétion (oui/non) : " completion

    sed -i "${id}s|.*|$id|$titre|$description|$lieu|$date_echeance $heure_echeance|$completion|" "$FICHIER_TACHES"
    echo "Tâche $id mise à jour."
}

# Fonction pour supprimer une tâche
supprimer_tache() {
    read -p "ID de la tâche à supprimer : " id
    if ! grep -q "^$id|" "$FICHIER_TACHES"; then
        erreur "ID de tâche non trouvé."
        return 1
    fi
    sed -i "/^$id|/d" "$FICHIER_TACHES"
    echo "Tâche $id supprimée."
}

# Fonction pour afficher les informations sur une tâche
afficher_tache() {
    read -p "ID de la tâche à afficher : " id
    if ! grep -q "^$id|" "$FICHIER_TACHES"; then
        erreur "ID de tâche non trouvé."
        return 1
    fi
    grep "^$id|" "$FICHIER_TACHES"
}

# Fonction pour lister les tâches pour un jour donné
lister_taches() {
    read -p "Date (AAAA-MM-JJ) : " date
    echo "Tâches complétées :"
    grep "|$date " "$FICHIER_TACHES" | grep "|oui$"
    echo "Tâches non complétées :"
    grep "|$date " "$FICHIER_TACHES" | grep "|non$"
}

# Fonction pour rechercher une tâche par titre
rechercher_tache() {
    read -p "Titre à rechercher : " titre
    grep "|$titre|" "$FICHIER_TACHES"
}

# Afficher les tâches d'aujourd'hui si aucun argument n'est passé
if [ $# -eq 0 ]; then
    date=$(date +%Y-%m-%d)
    echo "Tâches complétées aujourd'hui :"
    grep "|$date " "$FICHIER_TACHES" | grep "|oui$"
    echo "Tâches non complétées aujourd'hui :"
    grep "|$date " "$FICHIER_TACHES" | grep "|non$"
else
    case "$1" in
        creer) creer_tache ;;
        maj) mettre_a_jour_tache ;;
        supprimer) supprimer_tache ;;
        afficher) afficher_tache ;;
        lister) lister_taches ;;
        rechercher) rechercher_tache ;;
        *) erreur "Commande inconnue : $1" ;;
    esac
fi
