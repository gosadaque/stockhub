#!/bin/bash
#clear
export covestorlog="covestor.log"  #search history generated by covester.sh |tee output
export thelionlog="thelion.log"    #search history generated by thelion.sh.sh |tee output
export practicestocksforfun="practice-stocks-for-fun.log"    #search history generated by thelion.sh.sh |tee output
export redditchallenge2014="redditchallenge2014.log"
export daqian1="daqian1.log"
export daqian2="daqian2.log"

curl "http://finance.yahoo.com/q?s=$1" >tmp
export price=`cat tmp |egrep -o 'yfs_l84_[a-z]+">[0-9]+.[0-9]+' |cut -d'>' -f2`
export updownpercent=`cat tmp | grep $1 |egrep  -o "\([0-9]+.[0-9]+%\)" |head -n 1`
export updown=`cat tmp |grep $1 |egrep  -o 'alt="Up"|alt="Down"' |head -n 1 |cut -d'=' -f2 |sed -e 's/"//g' -e 's/Up/+/g' -e 's/Down/-/g'` 
export name=`cat tmp|egrep $1 |egrep 'content="'|egrep "q?s=$1"|cut -d',' -f2`
export time=`date +%m/%d/%Y`
echo $1:$price $updown$updownpercent $time
echo $name

curl "http://www.finviz.com/quote.ashx?t=$1" > tmp
cat tmp|grep center |grep fullview-links |grep tab-link |cut -d'>' -f4,6,8 |sed 's/<\/a/ /g'
echo "FA color-coded=============================="
for key in 'Market Cap' 'P/E' 'Forward P/E' 'P/C' 'P/FCF' 'P/B' 'Debt/Eq' 'Current Ratio' 'ROA' 'ROE' 'EPS next 5Y' 'Dividend %'
do
	color=`cat tmp |grep ">$key<" |egrep -o "color:#[0-9a]+" |cut -d':' -f2`
	val=`cat tmp |grep ">$key<" |egrep -o ">[0-9]+.[0-9]+<|>[0-9]+.[0-9]+B<|>[0-9]+.[0-9]+M<|>[0-9]+.[0-9]+%<" |sed -e 's/>//g' -e 's/<//g'`
	if [ "$color" == '#aa0000' ]; then 
		echo -e "$key:\t\t\e[00;31m$val\e[00m" 
	elif [ "$color" == '#008800' ]; then 
		echo -e "$key:\t\t\e[00;32m$val\e[00m" 
	else 
		echo -e "$key:\t\t$val"
    fi
done
echo "================================"
#gurufocus biz predicability
export predstar=`curl "http://www.gurufocus.com/gurutrades/$1" |grep "Business Predictability" |egrep -o "[0-9].[0-9]-Star<|[0-9]-Star<"  |cut -d'-' -f1`
echo -e "Predictability:\t" $predstar
#MSN StockScouter
export MSNStockScouter=`curl "http://investing.money.msn.com/investments/stock-ratings/?symbol=$1" |egrep -A 1 'class="rat"'  |tail -n 1 |tr -d ' '`
echo -e "MSN Rating:\t"$MSNStockScouter

#Crammer's MadMoney comments
export madmoneyurl="http://madmoney.thestreet.com/07/index.cfm?page=lookup"
export madmoneylookup="symbol=$1"
curl -d $madmoneylookup $madmoneyurl |egrep -m 1  ">[0-9]{2}/[0-9]{2}/200?" -A 20 >tmp1$$ #care the latest one
export maddate=`cat tmp1$$ |egrep -o "[0-9]{2}/[0-9]{2}/20[0-9][0-9]"`
export madbuysell=`cat tmp1$$ |egrep -o "[1-5]\.gif"|sed 's/.gif//g' |sed 's/5/SB/g'|sed 's/4/B/g'|sed 's/3/H/g'|sed 's/2/S/g'| sed 's/1/SS/g'`
export madvalue=`cat tmp1$$ |egrep -o "[0-9]+\.[0-9]+"|head -n 1`
export madchange=`cat tmp1$$ |egrep -o "\+ [0-9]+\.[0-9]+%|\- [0-9]+\.[0-9]+%"|tail -n 1`
echo -e "Crammer:\t"$maddate $madbuysell $madvalue $madchange

#w.r.t S&P 50MA
curl "http://download.finance.yahoo.com/d/quotes.csv?s=$1,SPY&f=m8" |cat -v |sed -e 's/%//g' -e 's/ //g' -e 's/\^M//g' |tr '\n' ' ' |awk '{print  "50MA vs. S&P:\t" $1" vs. "$2}'

#stoxline rating
export stoxline=`curl "http://www.stoxline.com/quote.php?symbol=BBW" |grep margin-bottom |grep "http://www.stoxline.com/pics/[0-9]s.png" |egrep  -o '[0-9]s.png' |sed 's/s.png/ stars/g'`
echo -e "Stoxline:\t"$stoxline

#MotleyFool's rating to be replace motley api
if [ ${FOOL_API_KEY+1} ] 
then  #apply for your own free key at http://developer.fool.com/, and set it in environment variable FOOL_API_KEY
export star=`curl "http://api.fool.com/caps/ws/Ticker/$1?apikey=$FOOL_API_KEY" |egrep -o 'Percentile="[0-5]"' |egrep -o "[0-5]"`
echo -e "Motely(0-5):\t"$star
fi


#Trend Spotter
trenspotter=`curl "http://www.stockta.com/cgi-bin/opinion.pl?symb=$1&num1=4&mode=stock"|sed 's/TR/\n/g' |grep "Trend Spotter"  |egrep -o ">Buy<|>Sell<|>Hold<" |sed -e 's/>//g' -e 's/<//g'`
echo -e "Trend Spotter:\t"$trenspotter

#Stock Picker rating
upper=`echo $1|tr a-z A-Z`
curl "http://www.stockpickr.com/symbol/$upper" |egrep "ratings" |grep "summary" |cut -d'>' -f4 |cut -d'<' -f1 |while read line
do
    echo -e "Stockpickr:\t"$line
done

#GStock
export lower=`echo $1|tr A-Z a-z`
curl http://www.gstock.com/quote/$lower.html |egrep -o "BUY|SELL"  |head -n 1 |while read line
do
    echo -e "GStock ALert:\t" $line
done

#guru focus fair value
curl "http://www.gurufocus.com/gurutrades/$1" |grep "Fair Value Votes for" |egrep -o 'call">\$[0-9]+.[0-9]+|call">\$[0-9]+' |cut -d'>' -f2 |while read fairvalue
do
echo -e "GuruFairValue:\t" $fairvalue
done

#TA pattern
export signal=`curl "http://www.americanbulls.com/SignalPage.aspx?lang=en&Ticker=$1" |grep "MainContent_LastSignal"|egrep -o ">[A-Z ]+</font>" |cut -d'<' -f1|cut -d'>' -f2`
export pattern=`curl "http://www.americanbulls.com/SignalPage.aspx?lang=en&Ticker=$1" |grep "MainContent_LastPattern"  |tail -n 1 | cut -d'>' -f3- |cut -d'<' -f1`
echo -e "USBull Signal\t" $signal 
echo -e "USBull Pattern\t" $pattern

found=$(grep -w $1 $covestorlog)
if [[ $? -eq 0 ]]; then
	echo "Covestor Top Manager Recent Transactions=================="
	echo "Stock Action Price Date Trade/Mon Return Manager Portfolio" |awk  '{printf "%-10s %-10s %-10s %-10s %-10s %-10s %-30s %-20s\n", $1,$2,$3,$4,$5,$6,$7,$8}'
	grep -w $1 $covestorlog
fi 

found=$(curl "http://stocks.covestor.com/$lower" |egrep -B 1000 -i "in the same sector" |egrep -A 1 'a href="http://covestor.com/[a-zA-Z]+|value positive|value negative')
if [[ $? -eq 0 ]]; then
	echo "Covestor Top Manager Current Holdings====================="
	echo "Manager Portfolio Sharp% Gain LongShort Price"|awk '{ printf "%-40s%-40s%10s%10s%10s%10s\n", $1, $2,$3,$4,$5,$6}'
	echo $found |egrep -o "http://covestor.com/[a-zA-Z0-9\-]+/[a-zA-Z0-9\-]+|[0-9]+.[0-9]+|-[0-9]+.[0-9]+" |sed "s/http:\/\/covestor.com//g" |tr '\n' ' ' |sed 's/ \//\n/g' |sed 's/^\///g' |sed 's/\// /g' |awk '{print $1" "$2" "$3" "$4}' |while read own
	do 		
		export manager=`echo $own|awk '{print $1}'`
		export portfolio=`echo $own|awk '{print $2}'`				
		export sharp=`echo $own|awk '{print $3}'`				
		export gain=`echo $own|awk '{print $4}'`				
		export longshort=`curl "http://covestor.com/$manager/$portfolio" |grep -A 10 "<td><a href=\"http://stocks.covestor.com/$lower" |head -n 12 |tail -n 3 |head -n 1|sed -e 's/Sell short/Short/g' -e 's/Buy to cover/Cover/g'`
		export price=`curl "http://covestor.com/$manager/$portfolio" |grep -A 10 "<td><a href=\"http://stocks.covestor.com/$lower" |head -n 12 |tail -n 1 |cut -d'>' -f2 |cut -d'<' -f1`
		echo $manager $portfolio $sharp $gain $longshort $price |awk '{ printf "%-40s%-40s%10s%10s%10s%10s\n", $1, $2,$3,$4,$5,$6}'
	done
fi

found=$(grep -w $1 $thelionlog)
if [[ $? -eq 0 ]]; then
	echo "TheLion Top Manager Recent Transactions==================="
	echo "User Stock Status Action Buydate Dummy Selldate dummy Buyprice Sellprice Gain%" |awk '{printf "%-15s %-5s %-10s %-7s %-10s %-10s %-10s %-10s %-10s\n",$1,$2,$3,$4,$5,$7,$9,$10,$11}'
	grep -w $1 $thelionlog
fi


export thismonth=`date +%m |sed 's/^0//g'`
export lastmonth=`date -d "1 month ago" +%m |sed 's/^0//g'`
export activitymonth="(0)?$thismonth/[0-9]+/(20)?`date +%y`|(0)?$lastmonth/[0-9]+/(20)?`date +%y`"
found=$(grep -w $1 $practicestocksforfun |egrep "$activitymonth")
if [[ $? -eq 0 ]]; then
	echo "MarketWatch Practice-stock-for-fun game Top players Recent Transactions==================="
	echo "Player Rank Stock Date Action Shares Price" |awk '{printf"%-30s %-5s %-10s %-10s %-10s %-10s %-10s\n",$1,$2,$3,$4,$5,$6,$7}'
	grep -w $1 $practicestocksforfun |egrep "$activitymonth"
fi
found=$(grep -w $1 $redditchallenge2014 |egrep $activitymonth)
if [[ $? -eq 0 ]]; then
	echo "MarketWatch RedditChallenge2014 game Top players Recent Transactions==================="
	echo "Player Rank Stock Date Action Shares Price" |awk '{printf"%-30s %-5s %-10s %-10s %-10s %-10s %-10s\n",$1,$2,$3,$4,$5,$6,$7}'
	grep -w $1 $redditchallenge2014 |egrep "$activitymonth"
fi
found=$(grep -w $1 $daqian1 |egrep $activitymonth)
if [[ $? -eq 0 ]]; then
	echo "MarketWatch DaQian-1 game Top players Recent Transactions==================="
	echo "Player Rank Stock Date Action Shares Price" |awk '{printf"%-30s %-5s %-10s %-10s %-10s %-10s %-10s\n",$1,$2,$3,$4,$5,$6,$7}'
	grep -w $1 $daqian1 |egrep "$activitymonth"
fi
found=$(grep -w $1 $daqian2 |egrep $activitymonth)
if [[ $? -eq 0 ]]; then
	echo "MarketWatch DaQian-2 game Top players Recent Transactions==================="
	echo "Player Rank Stock Date Action Shares Price" |awk '{printf"%-30s %-5s %-10s %-10s %-10s %-10s %-10s\n",$1,$2,$3,$4,$5,$6,$7}'
	grep -w $1 $daqian2 |egrep "$activitymonth"
fi

echo "Radar Screen----------------------------------------"
curl "http://www.grahaminvestor.com/screens/graham-intrinsic-value-stocks/" |egrep -o 'bc\?s=[A-Z.]+'|cut -d'=' -f2 |egrep -w "$1$" |sed "s/$1/Graham Intrinsic Value/g"
curl "http://www.grahaminvestor.com/screens/low-price-to-operating-cash-flow-ratio/" |egrep -o 'bc\?s=[A-Z.]+'|cut -d'=' -f2 |egrep -w "$1$" |sed "s/$1/Low Price to Operating CashFlow Raio/g"

curl "http://seekingalpha.com/analysis/investing-ideas/long-ideas" |egrep -o "/symbol/[a-z]+" |cut -d'/' -f3 |tr [:lower:]  [:upper:] |egrep -w "$1$" | sed "s/$1/SeekingAlphaLongIdea/g"
curl "http://seekingalpha.com/analysis/investing-ideas/short-ideas" |egrep -o "/symbol/[a-z]+" |cut -d'/' -f3 |tr [:lower:]  [:upper:] |egrep -w "$1$" |sed "s/$1/SeekingAlphaShortIdea/g"
curl "http://seekingalpha.com/analysis/investing-ideas/top-ideas" |egrep -o "/symbol/[a-z]+" |cut -d'/' -f3 |tr [:lower:]  [:upper:]  |egrep -w "$1$" |sed "s/$1/SeekingAlphaTopIdea/g"

curl "http://www.wenxuecity.com/bbs/archive.php?page=0&keyword=Long&SubID=finance&year=current" |egrep  -o -i "long [A-Za-z]+"  |grep -v term|grep -v target |grep -v bar |grep -v shadow |grep -v time |grep -v driveway |grep -v position |tr '[:lower:]' '[:upper:]' |sed 's/LONG //g' |sort |uniq |egrep -w "$1$" |sed "s/$1/DaQianLongIdea/g"

curl http://www.marketocracy.com/mds/teams |egrep -o "http://m100.marketocracy.com/[A-Za-z_]+" |while read portfolio
do
    curl "$portfolio/2portfolio/" |grep symbol |egrep -o ">[A-Z]+<" |sed -e 's/>//g' -e 's/<//g' |egrep -w "$1$" |sed "s/$1/MarketocracyTopHolding/g"
done

curl "http://www.insidercow.com/notLogin/buyByCompany.jsp?ORDER=asc&SORTBY=company_name&days=6" |egrep -o "company=[A-Z]+"|sort |uniq |cut -d'=' -f2 |egrep -w "$1$" |sed "s/$1/Insider Buy/g"

\rm -f tmp*

