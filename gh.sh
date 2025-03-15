set -e

echo "Do you want to setup github ssh? (y/n)"
read -r user_input
if [[ "$user_input" == "n" || "$user_input" == "N" ]]; then
    echo "Exiting script."
    exit 0
elif [[ "$user_input" == "y" || "$user_input" == "Y" ]]; then
    echo "Continuing with the setup..."
else
    echo "Invalid input. Please enter 'y' or 'n'."
    exit 1
fi

echo "Please enter your github username:"
read -r user_name
echo "Please enter your github email:"
read -r user_email

git config --global user.name "$user_name"
git config --global user.email "$user_email"

ssh-keygen -t ed25519 -C "$user_email" -f ~/.ssh/github_ed25519

PUBKEY=`cat ~/.ssh/github_ed25519.pub`
TITLE=`hostname`

echo "Please enter your github token. It must have admin:public_key permissions for DELETE"
read -r TOKEN

RESPONSE=`curl -s -H "Authorization: token ${TOKEN}" \
  -X POST --data-binary "{\"title\":\"${TITLE}\",\"key\":\"${PUBKEY}\"}" \
  https://api.github.com/user/keys`

# KEYID=`echo $RESPONSE \
#   | grep -o '"id.*' \
#   | grep -o "[0-9]*" \
#   | grep -m 1 "[0-9]*"`

echo "Public key deployed to remote service"

# Add SSH Key to the local ssh-agent"

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/github_ed25519

echo "Added SSH key to the ssh-agent"

# Test the SSH connection

ssh -T git@github.com

# add signing

curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer <YOUR-TOKEN>" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/user/gpg_keys \
  -d "{\"name\":\"${TITLE} GPG Key\",\"armored_public_key\":\"${PUBKEY}\"}"

git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/github_ed25519.pub
git config --global commit.gpgsign true
git config --global tag.gpgsign true

echo "Signing set up"
