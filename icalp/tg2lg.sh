sort -k1 -k2 -n -u icalp.tg > icalp_sorted.tg
cut -d' ' -f1,2 icalp_sorted.tg > icalp.lg
sed -i'.orig' -e 's/ /,/g' icalp.lg
rm icalp_sorted.tg
rm icalp.lg.orig