while IFS=$',' read mail team token; do
    #mail -s 'RuCTF 2014 Quals credentials' andrey.malets@gmail.com <<END
    mail -s 'RuCTF 2014 Quals credentials' $mail <<END
Hi, $team!

Here are your credentials for http://quals.ructf.org: $token

We'll send additional email to ructf@googlegroups.com
when the game starts (we still have a short delay).

Don't foget to subscribe!

-- RuCTF Team

END
done
