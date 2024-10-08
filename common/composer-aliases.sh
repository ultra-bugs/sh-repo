for phpbin in /usr/bin/php*; do
    if [[ -x "$phpbin" && "$phpbin" =~ /usr/bin/php[0-9]+\.[0-9]+$ ]]; then
        version=$(basename "$phpbin" | sed 's/php//')
        alias php$version="$phpbin"
        alias composer$version="php$version /usr/bin/composer"
    fi
done
