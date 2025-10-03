openssl genrsa -out ~/.ssh/snowflake_rsa_key 2048
openssl rsa -in ~/.ssh/snowflake_rsa_key -pubout -out ~/.ssh/snowflake_rsa_key.pub
chmod 600 ~/.ssh/snowflake_rsa_key