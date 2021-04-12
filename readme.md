# Momentum Portfolio Building Tool





Amongst the many trading strategies that the traders use, one of the most popular strategies is the momentum strategy. Traders measure momentum in many different ways to identify opportunity pockets. The core idea across all these strategies remains the same i.e to identify momentum and ride the wave. 

I have developed and back-tested several momentum trading strategies. I am currently using 4 of these strategies, which are run with different parameters, resulting in a total of 180 parameter-specific strategies. For proprietary reasons this is is not show publicly.

The current self-curated trading universe contains more than 8,500 stocks. It contains the most important stock identifiers, including ticker symbols for the country of origin stock exchange and ticker symbols for the German stock exchanges XETRA and Frankfurt. The tickers from these table are used to download daily historical data from data providers (yahoo).

<table class="table table-striped table-hover table-condensed" style="font-size: 6px; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> ISIN </th>
   <th style="text-align:left;"> WKN </th>
   <th style="text-align:left;"> Symbol </th>
   <th style="text-align:left;"> Symbol_XETRA </th>
   <th style="text-align:left;"> Symbol_FRA </th>
   <th style="text-align:left;"> Type </th>
   <th style="text-align:left;"> Instrument </th>
   <th style="text-align:left;"> Name </th>
   <th style="text-align:right;"> MCap_EUR </th>
   <th style="text-align:left;"> Industry </th>
   <th style="text-align:left;"> Sector </th>
   <th style="text-align:left;"> Location </th>
   <th style="text-align:left;"> Currency </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> AN8068571086 </td>
   <td style="text-align:left;"> 853390 </td>
   <td style="text-align:left;"> SLB </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> SCL.F </td>
   <td style="text-align:left;"> Stock </td>
   <td style="text-align:left;"> SCHLUMBERGER </td>
   <td style="text-align:left;"> Schlumberger Limited </td>
   <td style="text-align:right;"> 26707022160 </td>
   <td style="text-align:left;"> Energy </td>
   <td style="text-align:left;"> Oil &amp; Gas Equipment &amp; Services </td>
   <td style="text-align:left;"> AN </td>
   <td style="text-align:left;"> USD </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ANN4327C1220 </td>
   <td style="text-align:left;"> 855243 </td>
   <td style="text-align:left;"> HDG.AS </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> HUD.F </td>
   <td style="text-align:left;"> Stock </td>
   <td style="text-align:left;"> HUNTER DOUGLAS </td>
   <td style="text-align:left;"> Hunter Douglas N.V. </td>
   <td style="text-align:right;"> 1830000000 </td>
   <td style="text-align:left;"> Consumer Cyclical </td>
   <td style="text-align:left;"> Furnishings, Fixtures &amp; Appliances </td>
   <td style="text-align:left;"> AN </td>
   <td style="text-align:left;"> EUR </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AT000000STR1 </td>
   <td style="text-align:left;"> A0M23V </td>
   <td style="text-align:left;"> STR.VI </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> XD4.F </td>
   <td style="text-align:left;"> Stock </td>
   <td style="text-align:left;"> STRABAG </td>
   <td style="text-align:left;"> Strabag SE </td>
   <td style="text-align:right;"> 2811000000 </td>
   <td style="text-align:left;"> Industrials </td>
   <td style="text-align:left;"> Engineering &amp; Construction </td>
   <td style="text-align:left;"> AT </td>
   <td style="text-align:left;"> EUR </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AT00000AMAG3 </td>
   <td style="text-align:left;"> A1JFYU </td>
   <td style="text-align:left;"> AMAG.VI </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> AM8.F </td>
   <td style="text-align:left;"> Stock </td>
   <td style="text-align:left;"> AMAG AUSTRIA METALL AG </td>
   <td style="text-align:left;"> AMAG Austria Metall AG </td>
   <td style="text-align:right;"> 1001000000 </td>
   <td style="text-align:left;"> Basic Materials </td>
   <td style="text-align:left;"> Aluminum </td>
   <td style="text-align:left;"> AT </td>
   <td style="text-align:left;"> EUR </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AT00000FACC2 </td>
   <td style="text-align:left;"> A1147K </td>
   <td style="text-align:left;"> FACC.VI </td>
   <td style="text-align:left;"> 1FC.DE </td>
   <td style="text-align:left;"> 1FC.F </td>
   <td style="text-align:left;"> Stock </td>
   <td style="text-align:left;"> FACC AG </td>
   <td style="text-align:left;"> FACC AG </td>
   <td style="text-align:right;"> 416689000 </td>
   <td style="text-align:left;"> Industrials </td>
   <td style="text-align:left;"> Aerospace &amp; Defense </td>
   <td style="text-align:left;"> AT </td>
   <td style="text-align:left;"> EUR </td>
  </tr>
</tbody>
</table>


These stocks are filtered using information from top buy-side providers and social trading sites to define a trading basket containing ~500 stocks. This basket is used to assemble the stock portfolio.

The portfolio is assembled using the master file 01_master.daily.R in the src folder, which will basically source all other files in the folder. The result is summarized in a markdown report. 

This is an example of the portfolio from April, 2021

<div style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:300px; overflow-x: scroll; width:700px; "><table class="table table-striped table-hover table-condensed" style="font-size: 7px; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ISIN_instr </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> price </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> name </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> 2021-04-07 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> 2021-04-08 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> 2021-04-09 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> N </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> US72919P2020 </td>
   <td style="text-align:right;"> 27.4500 </td>
   <td style="text-align:left;"> PLUG POWER INC. DL-,01 </td>
   <td style="text-align:right;"> 0.059 </td>
   <td style="text-align:right;"> 0.054 </td>
   <td style="text-align:right;"> 0.043 </td>
   <td style="text-align:right;"> 158 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> US88160R1014 </td>
   <td style="text-align:right;"> 573.2000 </td>
   <td style="text-align:left;"> TESLA INC. </td>
   <td style="text-align:right;"> 0.048 </td>
   <td style="text-align:right;"> 0.048 </td>
   <td style="text-align:right;"> 0.042 </td>
   <td style="text-align:right;"> 8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> FR0011742329 </td>
   <td style="text-align:right;"> 34.1400 </td>
   <td style="text-align:left;"> MCPHY ENERGY S.A. EO 0,12 </td>
   <td style="text-align:right;"> 0.043 </td>
   <td style="text-align:right;"> 0.043 </td>
   <td style="text-align:right;"> 0.037 </td>
   <td style="text-align:right;"> 108 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> DE000A0JL9W6 </td>
   <td style="text-align:right;"> 37.1800 </td>
   <td style="text-align:left;"> VERBIO VER.BIOENERGIE  ON </td>
   <td style="text-align:right;"> 0.028 </td>
   <td style="text-align:right;"> 0.030 </td>
   <td style="text-align:right;"> 0.028 </td>
   <td style="text-align:right;"> 76 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CNE100000296 </td>
   <td style="text-align:right;"> 19.4000 </td>
   <td style="text-align:left;"> BYD </td>
   <td style="text-align:right;"> 0.032 </td>
   <td style="text-align:right;"> 0.032 </td>
   <td style="text-align:right;"> 0.027 </td>
   <td style="text-align:right;"> 138 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GB00B0130H42 </td>
   <td style="text-align:right;"> 5.5000 </td>
   <td style="text-align:left;"> ITM POWER PLC      LS-,05 </td>
   <td style="text-align:right;"> 0.032 </td>
   <td style="text-align:right;"> 0.032 </td>
   <td style="text-align:right;"> 0.026 </td>
   <td style="text-align:right;"> 478 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NO0010081235 </td>
   <td style="text-align:right;"> 2.5010 </td>
   <td style="text-align:left;"> NEL ASA            NK-,20 </td>
   <td style="text-align:right;"> 0.032 </td>
   <td style="text-align:right;"> 0.031 </td>
   <td style="text-align:right;"> 0.025 </td>
   <td style="text-align:right;"> 996 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CA39342L1085 </td>
   <td style="text-align:right;"> 22.8800 </td>
   <td style="text-align:left;"> GREEN THUMB INDS </td>
   <td style="text-align:right;"> 0.027 </td>
   <td style="text-align:right;"> 0.026 </td>
   <td style="text-align:right;"> 0.023 </td>
   <td style="text-align:right;"> 100 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CA0585861085 </td>
   <td style="text-align:right;"> 20.2900 </td>
   <td style="text-align:left;"> BALLARD PWR SYS </td>
   <td style="text-align:right;"> 0.030 </td>
   <td style="text-align:right;"> 0.029 </td>
   <td style="text-align:right;"> 0.023 </td>
   <td style="text-align:right;"> 112 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SE0007126024 </td>
   <td style="text-align:right;"> 230.4500 </td>
   <td style="text-align:left;"> XBT PROVIDER AB O.E. </td>
   <td style="text-align:right;"> 0.024 </td>
   <td style="text-align:right;"> 0.024 </td>
   <td style="text-align:right;"> 0.021 </td>
   <td style="text-align:right;"> 10 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SE0007525332 </td>
   <td style="text-align:right;"> 2296.2000 </td>
   <td style="text-align:left;"> XBT PROVIDER AB O.E. </td>
   <td style="text-align:right;"> 0.023 </td>
   <td style="text-align:right;"> 0.023 </td>
   <td style="text-align:right;"> 0.020 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> DE0007568578 </td>
   <td style="text-align:right;"> 25.5500 </td>
   <td style="text-align:left;"> SFC ENERGY AG </td>
   <td style="text-align:right;"> 0.025 </td>
   <td style="text-align:right;"> 0.024 </td>
   <td style="text-align:right;"> 0.020 </td>
   <td style="text-align:right;"> 78 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CA8536061010 </td>
   <td style="text-align:right;"> 2.4900 </td>
   <td style="text-align:left;"> STANDARD LITHIUM LTD </td>
   <td style="text-align:right;"> 0.023 </td>
   <td style="text-align:right;"> 0.023 </td>
   <td style="text-align:right;"> 0.019 </td>
   <td style="text-align:right;"> 762 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CA22587M1068 </td>
   <td style="text-align:right;"> 10.6000 </td>
   <td style="text-align:left;"> CRESCO LABS INC. SUB. VTG </td>
   <td style="text-align:right;"> 0.021 </td>
   <td style="text-align:right;"> 0.020 </td>
   <td style="text-align:right;"> 0.018 </td>
   <td style="text-align:right;"> 168 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GB00B18S7B29 </td>
   <td style="text-align:right;"> 0.7410 </td>
   <td style="text-align:left;"> AFC ENERGY PLC   LS -,001 </td>
   <td style="text-align:right;"> 0.023 </td>
   <td style="text-align:right;"> 0.022 </td>
   <td style="text-align:right;"> 0.017 </td>
   <td style="text-align:right;"> 2328 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GB00BG5KQW09 </td>
   <td style="text-align:right;"> 14.1200 </td>
   <td style="text-align:left;"> CERES POWER HLDGS  LS-,10 </td>
   <td style="text-align:right;"> 0.021 </td>
   <td style="text-align:right;"> 0.020 </td>
   <td style="text-align:right;"> 0.017 </td>
   <td style="text-align:right;"> 120 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> US35952H6018 </td>
   <td style="text-align:right;"> 10.6440 </td>
   <td style="text-align:left;"> FUELCELL ENERGY  DL-,0001 </td>
   <td style="text-align:right;"> 0.023 </td>
   <td style="text-align:right;"> 0.021 </td>
   <td style="text-align:right;"> 0.017 </td>
   <td style="text-align:right;"> 156 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SE0010296582 </td>
   <td style="text-align:right;"> 141.2500 </td>
   <td style="text-align:left;"> XBT PROVIDER AB O.E. </td>
   <td style="text-align:right;"> 0.015 </td>
   <td style="text-align:right;"> 0.017 </td>
   <td style="text-align:right;"> 0.016 </td>
   <td style="text-align:right;"> 12 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> US60770K1079 </td>
   <td style="text-align:right;"> 113.3000 </td>
   <td style="text-align:left;"> MODERNA INC.     DL-,0001 </td>
   <td style="text-align:right;"> 0.019 </td>
   <td style="text-align:right;"> 0.019 </td>
   <td style="text-align:right;"> 0.016 </td>
   <td style="text-align:right;"> 14 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> US8522341036 </td>
   <td style="text-align:right;"> 214.2500 </td>
   <td style="text-align:left;"> SQUARE INC. A </td>
   <td style="text-align:right;"> 0.013 </td>
   <td style="text-align:right;"> 0.014 </td>
   <td style="text-align:right;"> 0.013 </td>
   <td style="text-align:right;"> 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CA1973091079 </td>
   <td style="text-align:right;"> 5.1000 </td>
   <td style="text-align:left;"> COLUMBIA CARE INC. </td>
   <td style="text-align:right;"> 0.014 </td>
   <td style="text-align:right;"> 0.013 </td>
   <td style="text-align:right;"> 0.012 </td>
   <td style="text-align:right;"> 238 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> DE000A0TGJ55 </td>
   <td style="text-align:right;"> 121.8000 </td>
   <td style="text-align:left;"> VARTA AG O.N. </td>
   <td style="text-align:right;"> 0.013 </td>
   <td style="text-align:right;"> 0.013 </td>
   <td style="text-align:right;"> 0.012 </td>
   <td style="text-align:right;"> 10 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SE0006425815 </td>
   <td style="text-align:right;"> 24.4700 </td>
   <td style="text-align:left;"> POWERCELL SWEDEN  SK-,022 </td>
   <td style="text-align:right;"> 0.016 </td>
   <td style="text-align:right;"> 0.015 </td>
   <td style="text-align:right;"> 0.011 </td>
   <td style="text-align:right;"> 46 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> US5398301094 </td>
   <td style="text-align:right;"> 324.1000 </td>
   <td style="text-align:left;"> LOCKHEED MARTIN    DL 1 </td>
   <td style="text-align:right;"> 0.008 </td>
   <td style="text-align:right;"> 0.010 </td>
   <td style="text-align:right;"> 0.008 </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GB00B140Y116 </td>
   <td style="text-align:right;"> 0.8460 </td>
   <td style="text-align:left;"> PROTON MOTOR PWR S.LS-,01 </td>
   <td style="text-align:right;"> 0.010 </td>
   <td style="text-align:right;"> 0.010 </td>
   <td style="text-align:right;"> 0.008 </td>
   <td style="text-align:right;"> 990 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CA88105E1088 </td>
   <td style="text-align:right;"> 9.0500 </td>
   <td style="text-align:left;"> TERRASCEND CORP. </td>
   <td style="text-align:right;"> 0.010 </td>
   <td style="text-align:right;"> 0.009 </td>
   <td style="text-align:right;"> 0.008 </td>
   <td style="text-align:right;"> 92 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CA60040W1059 </td>
   <td style="text-align:right;"> 2.0950 </td>
   <td style="text-align:left;"> MILLENN.LITHIUM CORP. </td>
   <td style="text-align:right;"> 0.009 </td>
   <td style="text-align:right;"> 0.009 </td>
   <td style="text-align:right;"> 0.008 </td>
   <td style="text-align:right;"> 374 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CA05475P1099 </td>
   <td style="text-align:right;"> 23.2000 </td>
   <td style="text-align:left;"> AYR WELLNESS INC.RES.VTG. </td>
   <td style="text-align:right;"> 0.009 </td>
   <td style="text-align:right;"> 0.009 </td>
   <td style="text-align:right;"> 0.008 </td>
   <td style="text-align:right;"> 34 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> DE000A161408 </td>
   <td style="text-align:right;"> 69.2400 </td>
   <td style="text-align:left;"> HELLOFRESH SE  INH O.N. </td>
   <td style="text-align:right;"> 0.006 </td>
   <td style="text-align:right;"> 0.006 </td>
   <td style="text-align:right;"> 0.007 </td>
   <td style="text-align:right;"> 10 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SE0005003217 </td>
   <td style="text-align:right;"> 4.8020 </td>
   <td style="text-align:left;"> CELL IMPACT AB B </td>
   <td style="text-align:right;"> 0.008 </td>
   <td style="text-align:right;"> 0.008 </td>
   <td style="text-align:right;"> 0.007 </td>
   <td style="text-align:right;"> 142 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> US0937121079 </td>
   <td style="text-align:right;"> 21.5400 </td>
   <td style="text-align:left;"> BLOOM ENERGY A   DL-,0001 </td>
   <td style="text-align:right;"> 0.009 </td>
   <td style="text-align:right;"> 0.008 </td>
   <td style="text-align:right;"> 0.007 </td>
   <td style="text-align:right;"> 32 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> US5949181045 </td>
   <td style="text-align:right;"> 212.2500 </td>
   <td style="text-align:left;"> MICROSOFT CORP. DL -,001 </td>
   <td style="text-align:right;"> 0.007 </td>
   <td style="text-align:right;"> 0.007 </td>
   <td style="text-align:right;"> 0.007 </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CH0454664027 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> 21SHARES ETHER ETP OE </td>
   <td style="text-align:right;"> 0.007 </td>
   <td style="text-align:right;"> 0.007 </td>
   <td style="text-align:right;"> 0.006 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> US30303M1027 </td>
   <td style="text-align:right;"> 260.8500 </td>
   <td style="text-align:left;"> FACEBOOK INC. </td>
   <td style="text-align:right;"> 0.006 </td>
   <td style="text-align:right;"> 0.007 </td>
   <td style="text-align:right;"> 0.006 </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> US69608A1088 </td>
   <td style="text-align:right;"> 19.3740 </td>
   <td style="text-align:left;"> PALANTIR TECHNOLOGIES INC </td>
   <td style="text-align:right;"> 0.007 </td>
   <td style="text-align:right;"> 0.007 </td>
   <td style="text-align:right;"> 0.006 </td>
   <td style="text-align:right;"> 32 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> US67066G1040 </td>
   <td style="text-align:right;"> 480.0500 </td>
   <td style="text-align:left;"> NVIDIA CORP.      DL-,001 </td>
   <td style="text-align:right;"> 0.007 </td>
   <td style="text-align:right;"> 0.007 </td>
   <td style="text-align:right;"> 0.006 </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> DE0007100000 </td>
   <td style="text-align:right;"> 74.0100 </td>
   <td style="text-align:left;"> DAIMLER </td>
   <td style="text-align:right;"> 0.007 </td>
   <td style="text-align:right;"> 0.007 </td>
   <td style="text-align:right;"> 0.006 </td>
   <td style="text-align:right;"> 8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> US77543R1023 </td>
   <td style="text-align:right;"> 309.2000 </td>
   <td style="text-align:left;"> ROKU INC   CL. A DL-,0001 </td>
   <td style="text-align:right;"> 0.006 </td>
   <td style="text-align:right;"> 0.007 </td>
   <td style="text-align:right;"> 0.006 </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> DE000A0S9GB0 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> DB GOLD OEZT </td>
   <td style="text-align:right;"> 0.007 </td>
   <td style="text-align:right;"> 0.006 </td>
   <td style="text-align:right;"> 0.005 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> US0090661010 </td>
   <td style="text-align:right;"> 152.0800 </td>
   <td style="text-align:left;"> AIRBNB INC.     DL-,01 </td>
   <td style="text-align:right;"> 0.007 </td>
   <td style="text-align:right;"> 0.006 </td>
   <td style="text-align:right;"> 0.005 </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> AT0000A00XX9 </td>
   <td style="text-align:right;"> 10.4600 </td>
   <td style="text-align:left;"> POLYTEC HOLDING AG </td>
   <td style="text-align:right;"> 0.007 </td>
   <td style="text-align:right;"> 0.007 </td>
   <td style="text-align:right;"> 0.005 </td>
   <td style="text-align:right;"> 52 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> DE000A0HL8N9 </td>
   <td style="text-align:right;"> 89.1000 </td>
   <td style="text-align:left;"> 2G ENERGY AG </td>
   <td style="text-align:right;"> 0.006 </td>
   <td style="text-align:right;"> 0.006 </td>
   <td style="text-align:right;"> 0.005 </td>
   <td style="text-align:right;"> 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> US0126531013 </td>
   <td style="text-align:right;"> 122.6500 </td>
   <td style="text-align:left;"> ALBEMARLE CORP.    DL-,01 </td>
   <td style="text-align:right;"> 0.007 </td>
   <td style="text-align:right;"> 0.006 </td>
   <td style="text-align:right;"> 0.005 </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> KYG3777B1032 </td>
   <td style="text-align:right;"> 2.2715 </td>
   <td style="text-align:left;"> GEELY AUTO. HLDGS  HD-,02 </td>
   <td style="text-align:right;"> 0.006 </td>
   <td style="text-align:right;"> 0.006 </td>
   <td style="text-align:right;"> 0.005 </td>
   <td style="text-align:right;"> 230 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NO0003067902 </td>
   <td style="text-align:right;"> 4.7540 </td>
   <td style="text-align:left;"> HEXAGON COMPOSITES ASA </td>
   <td style="text-align:right;"> 0.006 </td>
   <td style="text-align:right;"> 0.006 </td>
   <td style="text-align:right;"> 0.005 </td>
   <td style="text-align:right;"> 104 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CH0454664043 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> 21SHARES RIPPLEXRP ETP OE </td>
   <td style="text-align:right;"> 0.004 </td>
   <td style="text-align:right;"> 0.004 </td>
   <td style="text-align:right;"> 0.005 </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> US09075V1026 </td>
   <td style="text-align:right;"> 96.3000 </td>
   <td style="text-align:left;"> BIONTECH SE SPON. ADRS 1 </td>
   <td style="text-align:right;"> 0.005 </td>
   <td style="text-align:right;"> 0.005 </td>
   <td style="text-align:right;"> 0.005 </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> DK0061414711 </td>
   <td style="text-align:right;"> 62.7800 </td>
   <td style="text-align:left;"> EVERFUEL A/S    DK -,10 </td>
   <td style="text-align:right;"> 0.005 </td>
   <td style="text-align:right;"> 0.005 </td>
   <td style="text-align:right;"> 0.004 </td>
   <td style="text-align:right;"> 8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> US47759T1007 </td>
   <td style="text-align:right;"> 32.8400 </td>
   <td style="text-align:left;"> JINKOSOLAR ADR/4 DL-00002 </td>
   <td style="text-align:right;"> 0.005 </td>
   <td style="text-align:right;"> 0.005 </td>
   <td style="text-align:right;"> 0.004 </td>
   <td style="text-align:right;"> 14 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CA82509L1076 </td>
   <td style="text-align:right;"> 1018.0000 </td>
   <td style="text-align:left;"> SHOPIFY A SUB.VTG </td>
   <td style="text-align:right;"> 0.005 </td>
   <td style="text-align:right;"> 0.005 </td>
   <td style="text-align:right;"> 0.004 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
</tbody>
</table></div>



