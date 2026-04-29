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

# Criando a Hierarquia Padrão de diretórios
echo 
echo "IÇAR AS VELAS! (Criando diretórios padrão)"

# Do sistema
mkdir ~/Backups 
mkdir ~/Desktop 
mkdir ~/Documents 
mkdir ~/Downloads 
mkdir ~/Music
mkdir ~/Videos
mkdir ~/Pictures 

# Das config
mkdir ~/.config
mkdir ~/.config/nvim 
mkdir ~/.config/sway 
mkdir ~/.config/waybar
mkdir ~/.config/kew 
mkdir ~/.config/foot 

echo
echo "LARGUEM AS AMARRAS! (Criando Symlinks)"

# Variáveis de Atalho
CONF="$REPO/config"
LOCAL="$HOME/.config"

# Gerais (Arquivos que ficam na raiz do seu ~)
ln -sf "$CONF/bashrc"       "$HOME/.bashrc"
ln -sf "$CONF/bash_profile" "$HOME/.bash_profile"
ln -sf "$CONF/tmux.conf"    "$HOME/.tmux.conf"

# Em específico (Arquivos que vão para dentro de .config)
ln -sf "$CONF/nvim_init.lua" "$LOCAL/nvim/init.lua"
ln -sf "$CONF/sway.conf"      "$LOCAL/sway/config"
ln -sf "$CONF/hotkeys.txt"    "$LOCAL/sway/hotkeys.txt"
ln -sf "$CONF/waybar.conf"    "$LOCAL/waybar/config"
ln -sf "$CONF/waybar.css"     "$LOCAL/waybar/style.css"
ln -sf "$CONF/foot.ini"       "$LOCAL/foot/foot.ini"

echo
echo "GUARNIÇÃO, AS PEÇAS! (Instalando coisas)"

# Atualizar primeiro
sudo pacman -Syu

# Git, Why
sudo pacman -Sy git 
git clone https://github.com/theE008/why.git ~/.config/why/

# Yay
sudo pacman -S --needed base-devel 
git clone https://aur.archlinux.org/yay.git
(cd yay && makepkg -si)

# Salvando como variável
REASONS_SCRIPT="$REPO/reasons/install.bash"

# Só garantiir que existe mesmo
if [[ -f "$REASONS_SCRIPT" ]]; then
    # 'source' executa o conteúdo do arquivo no shell atual
    source "$REASONS_SCRIPT"
else
    echo "Aviso: Nenhum manifesto encontrado em $REASONS_SCRIPT"
fi

source ~/.bashrc

echo 
echo "FRAGATA PRONTA PARA USO"
echo
