#!/bin/bash
#clear
export covestorlog="covestor.log"  #search history generated by covester.sh |tee output
export thelionlog="thelion.log"    #search history generated by thelion.sh.sh |tee output
export marketwatchlog="marketwatch-*.log"
export foollog="fool.log"
export marketocracy="marketocracy.log"

curl "https://www.google.com/finance?q=$1" |egrep -o "id:\"[0-9]+\",values:\[[^}]+"  |egrep $1  |cut -d'[' -f2 |sed -e 's/"//g' |cut -d',' -f1,2,3,4,6 |awk -F',' '{printf "%s,%s \n$%s %s %s%\n",$1,$2,$3,$4,$5}'
#|cut -d'[' -f2 |sed -e 's/"//g' |cut -d',' -f1,2,3,4,6 |awk -F',' '{printf "%s,%s \n$%s %s %s%",$1,$2,$3,$4,$5}'

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
export sp500avgpe=`curl http://www.multpl.com/ |grep "> S&amp;P 500 PE Ratio<" |egrep -o '[0-9]{2}\.[0-9]{2}'`
echo -e "S&P 500 avg PE:" $sp500avgpe
#gurufocus biz predicability
export predstar=`curl "http://www.gurufocus.com/gurutrades/$1" |grep "Business Predictability" |egrep -o "[0-9].[0-9]-Star<|[0-9]-Star<"  |cut -d'-' -f1`
echo -e "Predictability:\t" $predstar

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
export stoxline=`curl "http://www.stoxline.com/quote.php?symbol=$1" |grep margin-bottom |grep "http://www.stoxline.com/pics/[0-9]s.png" |egrep  -o '[0-9]s.png' |sed 's/s.png/ stars/g'`
echo -e "Stoxline:\t"$stoxline

#MotleyFool's rating to be replace motley api
if [ ${FOOL_API_KEY} ] 
then  #apply for your own free key at http://developer.fool.com/, and set it in environment variable FOOL_API_KEY
export star=`curl "http://www.fool.com/a/caps/ws/Ticker/$1?apikey=$FOOL_API_KEY" |egrep -o 'Percentile="[0-5]"' |egrep -o "[0-5]"`
echo -e "MotelyFool:\t"$star
fi


#Trend Spotter
#trenspotter=`curl "http://www.stockta.com/cgi-bin/opinion.pl?symb=$1&num1=4&mode=stock"|sed 's/TR/\n/g' |grep "Trend Spotter"  |egrep -o ">Buy<|>Sell<|>Hold<" |sed -e 's/>//g' -e 's/<//g'`
#echo -e "Trend Spotter:\t"$trenspotter

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
export signal=`curl "https://www.americanbulls.com/SignalPage.aspx?lang=en&Ticker=$1" |grep "MainContent_LastSignal"|egrep -o ">[A-Z ]+</font>" |cut -d'<' -f1|cut -d'>' -f2`
export pattern=`curl "https://www.americanbulls.com/SignalPage.aspx?lang=en&Ticker=$1" |grep "MainContent_LastPattern"  |tail -n 1 | cut -d'>' -f3- |cut -d'<' -f1`
echo -e "USBull Signal\t" $signal 
echo -e "USBull Pattern\t" $pattern

echo "Headline/Article/Blogs----------------------------------------"
curl "http://finance.yahoo.com/q?s=$1" |grep 'yfi_quote_headline' |sed 's/;">/\n/g' |grep cite |cut -d '<' -f1 |awk '{print "<YAHOO>"$0}' |head -n 2
curl "http://seekingalpha.com/symbol/$1" |egrep -o 'qp_latest">.+<' |cut -d'<' -f1 |cut -d '>' -f2 |head -n 2

echo "Radar Screen----------------------------------------"
curl "http://x-fin.com/stocks/screener/graham-dodd/"    |egrep -A 1 "The complete list of" |egrep -o -w $1 |sed "s/$1/Graham-Dodd-Value/g"
curl "http://x-fin.com/stocks/screener/graham-formula/" |egrep -A 1 "The complete list of" |egrep -o -w $1 |sed "s/$1/Graham-Formula-Value/g"

curl "http://seekingalpha.com/stock-ideas/long-ideas"  |grep bull |egrep -o "\/symbol\/[a-zA-Z0-9\-\.]+"  |cut -d'/' -f3 |tr [:lower:]  [:upper:]|egrep -w "$1$" | sed "s/$1/SeekingAlphaLongIdea/g"
curl "http://seekingalpha.com/stock-ideas/short-ideas" |grep bull |egrep -o "\/symbol\/[a-zA-Z0-9\-\.]+"  |cut -d'/' -f3 |tr [:lower:]  [:upper:]|egrep -w "$1$" |sed "s/$1/SeekingAlphaShortIdea/g"
curl "http://seekingalpha.com/stock-ideas/top-ideas"   |grep bull |egrep -o "\/symbol\/[a-zA-Z0-9\-\.]+"  |cut -d'/' -f3 |tr [:lower:]  [:upper:]  |egrep -w "$1$" |sed "s/$1/SeekingAlphaTopIdea/g"

egrep -w "^$1," $marketocracy  |sed "s/$1/MarketoCracy Master Top Holding/g"

curl "http://www.insidercow.com/notLogin/buyByCompany.jsp?ORDER=asc&SORTBY=company_name&days=6" |egrep -o "company=[A-Z]+"|sort |uniq |cut -d'=' -f2 |egrep -w "$1$" |sed "s/$1/Insider Buy/g"


found=$(grep -w $1 $covestorlog)
if [[ $? -eq 0 ]]; then
	echo "===Covestor Top Manager Recent Transactions=================="
	echo "Stock Action Price Date Trade/Mon Return Manager Portfolio" |awk  '{printf "%-10s %-10s %-10s %-10s %-10s %-10s %-30s %-20s\n", $1,$2,$3,$4,$5,$6,$7,$8}'
	grep -w $1 $covestorlog
fi 
found=$(grep -w $1 $foollog)
if [[ $? -eq 0 ]]; then
	echo "===FoolPlayer Rating Date Ticker Price==================="
 	grep -w $1 $foollog
fi
found=$(cat $thelionlog |grep "Active" |grep -w $1)
if [[ $? -eq 0 ]]; then
	echo "===LionUser     Stock Status     Action  Buydate    Selldate   Buyprice   Sellprice  Gain%"
	grep -w $1 $thelionlog |grep "Active"
fi 
export thismonth=`date +%m |sed 's/^0//g'`
export lastmonth=`date -d "1 month ago" +%m |sed 's/^0//g'`
export activitymonth="(0)?$thismonth/[0-9]+/(20)?`date +%y`|(0)?$lastmonth/[0-9]+/(20)?`date +%y`"
found=$(grep -w $1 $marketwatchlog |egrep $activitymonth)
if [[ $? -eq 0 ]]; then
	echo "===MarketWatchPlayer Rank Stock Date Action Shares Price" |awk '{printf"%-30s %-5s %-10s %-10s %-10s %-10s %-10s\n",$1,$2,$3,$4,$5,$6,$7}'
	grep -w $1 $marketwatchlog |egrep "$activitymonth" |cut -d':' -f2-
fi


\rm -f tmp*

