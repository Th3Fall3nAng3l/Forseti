#!/bin/bash

#~~~~~~~~~~~~~~~~~~~~#
#                    #
# Forseti v1.0       #
# Distribution Linux #
# Auteur : Expinfo   #
#                    #
#~~~~~~~~~~~~~~~~~~~~#

#~~~~~Variables modifiables~~~~~

User="freebox" #Nom d'utilisateur pour la connexion au SFTP

Passwd="7VF9hf64n!N79" #Mdp pour la connexion au SFTP

Server="cyber-lab.hd.free.fr"

ServerPort="22731"

ServerRep="FTP_EXPINFO/Forseti_DFIR/"

NetMask="192.168.1.0/24" #Plage d'adresse ip a scanner

SuUsername="root"

SuPasswd="JeSuis1Mot2Passe"

#~~~~~Variables statiques~~~~~

RepPC=$PWD

#~~~~~Initialisation~~~~~

clear
if [ $UID != "0" ]
then
  echo "Vous n'avez pas les droits requis pour l'execution du programme..."
  printf '\u274c Erreur.\n' | iconv -f UTF-8
  exit 1
fi

echo -e "Création des dossiers temporaires et récupération des ressources..."

spin() {
  spinner='/|\\-/|\\-'
  while :
  do
    for i  in `seq 0 7`
    do 
      echo -n "${spinner:$i:1}"
      echo -en "\010"
      sleep 0.2
    done
  done
}
spin &
SPIN_ID=$!
disown


#~~~~~Mise en place des dossiers temporaires~~~~~

mkdir $RepPC/Temp_Expinfo_CyLR
mkdir $RepPC/Temp_Expinfo_CyLR/Tools
mkdir $RepPC/Temp_Expinfo_CyLR/Temps

#~~~~~Installation des outils~~~~~

cd $RepPC/Temp_Expinfo_CyLR/Tools
apt-get -qq -y install git
apt-get -qq -y install sshpass
apt-get -qq -y install pssh
apt-get -qq -y install curl
apt-get -qq -y install nmap
mkdir $RepPC/Temp_Expinfo_CyLR/Tools/CyLR
cd $RepPC/Temp_Expinfo_CyLR/Tools/CyLR
curl -s --ftp-ssl --insecure ftp://$Server:$ServerPort/FTP_EXPINFO/CyLR/CyLRLinux.zip -u $User:$Passwd --output CyLRLinux.zip
unzip CyLRLinux.zip > /dev/null
rm -rf CyLRLinux.zip

kill -9 $SPIN_ID > /dev/null
printf '[\342\234\224] Fait.\n' | iconv -f UTF-8

#~~~~~Initialisation de Nmap pour créer une liste d'adresse ip connectées~~~~~

echo -e "\nAnalyse du réseau..."

spin() {
  spinner='/|\\-/|\\-'
  while :
  do
    for i  in `seq 0 7`
    do 
      echo -n "${spinner:$i:1}"
      echo -en "\010"
      sleep 0.2
    done
  done
}
spin &
SPIN_ID=$!
disown

nmap -n -sn $NetMask -oG - | awk '/Up$/{print $2}' > Liste_Adresse.txt #Récupération des adresses sur le réseau pour le lancement en parallèle de la récup de ressources
mv Liste_Adresse.txt $RepPC/Temp_Expinfo_CyLR/Temps
cd $RepPC/Temp_Expinfo_CyLR/Temps
sed -i 's/^/'$SuUsername'@/' Liste_Adresse.txt

kill -9 $SPIN_ID > /dev/null
printf '[\342\234\224] Fait.\n' | iconv -f UTF-8

#~~~~~Lancement en parallele de la récupération de ressources~~~~~

echo -e "\nRécupération des données importantes, cette opération peut être longue..."

spin() {
  spinner='/|\\-/|\\-'
  while :
  do
    for i  in `seq 0 7`
    do 
      echo -n "${spinner:$i:1}"
      echo -en "\010"
      sleep 0.2
    done
  done
}
spin &
SPIN_ID=$!
disown

cd $RepPC/Temp_Expinfo_CyLR/Temps
cat Liste_Adresse.txt | while read line;
do
  sshpass -p $SuPasswd ssh -o "StrictHostKeyChecking=no" -n $line "apt-get -y install curl; apt-get -y install unzip; mkdir /Temp_Expinfo; cd /Temp_Expinfo; curl -s --ftp-ssl --insecure ftp://$Server:$ServerPort/FTP_EXPINFO/Forseti_DFIR/Ressources/Forseti_pssh.sh -u $User:$Passwd --output Forseti_pssh.sh; chmod 755 Forseti_pssh.sh; ./Forseti_pssh.sh"
done

#cd $RepPC/Temp_Expinfo_CyLR/Tools/CyLR
#./CyLR -q -of "$HOSTNAME"_CyLR.zip >/dev/null #Lancement de l'outil CyLR
#curl -s --ftp-ssl --insecure -T "$HOSTNAME"_CyLR.zip ftp://$Server:$ServerPort/$ServerRep/ --user $User:$Passwd #Transfert du fichier .zip obtenu sur le serveur ftp avec un protocole ssl
#printf '[\342\234\224] Fait.\n' | iconv -f UTF-8

kill -9 $SPIN_ID > /dev/null

#~~~~~Supression des dossiers temporaires~~~~~

echo -e "\nSupression des dossiers temporaires..."

cd $RepPC
rm -rf ./Temp_Expinfo_CyLR

printf '[\342\234\224] Fait.\n' | iconv -f UTF-8

#~~~~~Fin~~~~~

printf "\n[\342\234\224] ${RED}Récupération terminée.\n" | iconv -f UTF-8
