#!/bin/bash
clear

#~~~~~Variables modifiables~~~~~

User="freebox" #Nom d'utilisateur pour la connexion au SFTP
Passwd="7VF9hf64n!N79" #Mdp pour la connexion au SFTP
Server="cyber-lab.hd.free.fr"
ServerPort="22731"
ServerRep="FTP_EXPINFO/Forseti_DFIR/"
NetMask="192.168.1.0/24" #Masque du réseau
SuPasswd="JeSuis1Mot2Passe"

#~~~~~Variables statiques~~~~~

RepPC=$PWD
NOW=$( date '+%F' )

#~~~~~Initialisation~~~~~

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
wget -q https://github.com/orlikoski/CyLR/releases/download/2.2.0/CyLR_linux-x64.zip
unzip CyLR_linux-x64.zip > /dev/null
rm -rf CyLR_linux-x64.zip

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
sshpass -p $SuPasswd parallel-ssh -h Liste_Adresse.txt -A -l root 'apt-get -qq -y install git; mkdir /Temp_Expinfo_CyLR; cd /Temp_Expinfo_CyLR; git clone https://github.com/Th3Fall3nAng3l/Forseti_pssh; cd Forseti_pssh;chmod 755 ./Forseti_pssh.sh ;./Forseti_pssh.sh'

cd $RepPC/Temp_Expinfo_CyLR/Tools/CyLR
./CyLR -q -of "$NOW"_"$HOSTNAME"_CyLR.zip >/dev/null #Lancement de l'outil CyLR
curl -s --ftp-ssl --insecure -T "$NOW"_"$HOSTNAME"_CyLR.zip ftp://$Server:$ServerPort/$ServerRep/ --user $User:$Passwd #Transfert du fichier .zip obtenu sur le serveur ftp avec un protocole ssl
printf '[\342\234\224] Fait.\n' | iconv -f UTF-8

kill -9 $SPIN_ID > /dev/null

#~~~~~Supression des dossiers temporaires~~~~~

echo -e "\nSupression des dossiers temporaires..."

cd $RepPC
rm -rf ./Temp_Expinfo_CyLR

printf '[\342\234\224] Fait.\n' | iconv -f UTF-8

#~~~~~Fin~~~~~

printf "\n[\342\234\224] ${RED}Récupération terminée.\n" | iconv -f UTF-8
