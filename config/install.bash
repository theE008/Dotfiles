#!/bin/bash 

# Avisando a inicialização
clear 

echo "# ---------------------------------------"
echo "# Kavatron Dotfile Distro Para Arch Linux"
echo "# ---------------------------------------"
echo
echo "Por Thiago Pereira de Oliveira (theE008)"
echo "Saiba mais em https://github.com/theE008/Dotfiles"
echo
echo "!!! ATENÇÃO, CAPITÃO !!!"
echo "Este Script irá fazer diversas modificações neste computador"
echo "Tal é feito apenas para uso numa Fresh Install de Arch Linux"
echo "Não execute em outros casos."
echo 
read -p "Prosseguir? (ye/Nai): " confirmar

# Garantir que o usuário sabe o que faz
if [[ 
    "$confirmar" != "y"  && 
    "$confirmar" != "Y"  &&
    "$confirmar" != "ye" && 
    "$confirmar" != "Ye" &&
    "$confirmar" != "YE" 
   ]]; then

    echo
    echo "Entendido capitão, abandonar navio."
    echo 

    exit 1
fi

# Variável do local 
REPO="$HOME/Dotfiles"

# Garantindo que o repositório está no lugar certo 
if [[ ! -d "$REPO" ]]; then 

    echo
    echo "!!! ERRO !!!"
    echo "A fragata não se encontra no porto, Capitão!"
    echo 
    echo "Este repo deve estar dentro de: $HOME/Dotfiles"
    echo "Mova o Dir 'Dotfiles' para o seu ~ e tente novamente."
    echo

    exit 1
fi

# Garantir sudo 
sudo -v
# Keep-alive: update existing sudo time stamp if the script takes a while
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Criando a Hierarquia Padrão de diretórios
echo 
echo "IÇAR AS VELAS! (Criando diretórios padrão)"

# Do sistema
mkdir ~/Backups 
mkdir ~/Desktop 
mkdir ~/Desktop/Snippets
mkdir ~/Desktop/Old
mkdir ~/Documents 
mkdir ~/Documents/Diary 
mkdir ~/Documents/Notes
mkdir ~/Documents/Narrate
mkdir ~/Downloads 
mkdir ~/Music
mkdir ~/Videos
mkdir ~/Videos/OBS
mkdir ~/Pictures 
mkdir ~/Pictures/Screenshots

# Das config
mkdir ~/.config
mkdir ~/.config/nvim 
mkdir ~/.config/sway 
mkdir ~/.config/waybar
mkdir ~/.config/kew 
mkdir ~/.config/foot 
mkdir ~/.w3m # Muito velho pra ser padrão
mkdir -p ~/.config/obs-studio/basic/profiles/Untitled # Estrutura esquisita do obs
mkdir -p ~/.config/obs-studio/basic/scenes

echo
echo "LARGUEM AS AMARRAS! (Criando Symlinks)"

# Variáveis de Atalho
CONF="$REPO/config"
LOCAL="$HOME/.config"

# Gerais (Arquivos que ficam na raiz do seu ~)
ln -sf "$CONF/bashrc"       "$HOME/.bashrc"
ln -sf "$CONF/bash_profile" "$HOME/.bash_profile"
ln -sf "$CONF/tmux.conf"    "$HOME/.tmux.conf"
ln -sf "$CONF/w3m.conf"     "$HOME/.w3m/config"

# Em específico (Arquivos que vão para dentro de .config)
ln -sf "$CONF/nvim_init.lua"  "$LOCAL/nvim/init.lua"
ln -sf "$CONF/sway.conf"      "$LOCAL/sway/config"
ln -sf "$CONF/hotkeys.txt"    "$LOCAL/sway/hotkeys.txt"
ln -sf "$CONF/waybar.conf"    "$LOCAL/waybar/config"
ln -sf "$CONF/waybar.css"     "$LOCAL/waybar/style.css"
ln -sf "$CONF/foot.ini"       "$LOCAL/foot/foot.ini"
ln -sf "$CONF/obs.ini"        "$LOCAL/obs-studio/global.ini"
ln -sf "$CONF/obs.basic"      "$LOCAL/obs-studio/basic/profiles/Untitled/basic.ini"
ln -sf "$CONF/obs.json"        "$LOCAL/obs-studio/basic/scenes/Untitled.json"
echo
echo "GUARNIÇÃO, AS PEÇAS! (Instalando coisas)"

# Atualizar primeiro
sudo pacman -Syu --noconfirm

# Git, Why
sudo pacman -Sy git --noconfirm
git clone https://github.com/theE008/why.git ~/.config/why/

# Yay
sudo pacman -S --needed base-devel --noconfirm
git clone https://aur.archlinux.org/yay.git /tmp/yay
(cd /tmp/yay && makepkg -si --noconfirm)
rm -rf /tmp/yay

# Multilib
sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf && sudo pacman -Syu --noconfirm

# Salvando como variável
REASONS_SCRIPT="$REPO/reasons/install.bash"

# Só garantiir que existe mesmo
if [[ -f "$REASONS_SCRIPT" ]]; then
    # 'source' executa o conteúdo do arquivo no shell atual
    source "$REASONS_SCRIPT"
else
    echo "Aviso: Nenhum manifesto encontrado em $REASONS_SCRIPT"
fi

echo 
echo "DEEM CORDA! (Arrumando relógio)"
sudo timedatectl set-timezone America/Sao_Paulo
sudo timedatectl set-ntp true

echo 
echo "AGRADEÇAM AO MAR AZUL (Ativando bluetooth)"
sudo systemctl enable --now bluetooth

echo 
echo "TRANQUEM A ESCOTILHA (Ativando firewall)"
sudo ufw default deny incoming
sudo ufw default allow outgoing
# Permissões
sudo ufw allow ssh
sudo ufw allow syncthing
sudo systemctl enable --now ufw.service
sudo ufw --force enable

source ~/.bashrc

echo 
echo "FRAGATA PRONTA PARA USO (Considere reiniciar o PC)"
echo
