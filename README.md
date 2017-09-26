# stages-to-strava
conversion of [Stages indoor bike](https://stagescycling.com/global/indoor/) .csv files to garmin .tcx to be able to upload to [Strava](https://www.strava.com/)




1. install ruby on your system 
1. run `git clone git@github.com:moonflash/stages-to-strava.git`
3. `cd STAGES`
2. install nokogiri `gem install nokogiri`
3. copy/paste your stages.csv files to `STAGES/original` directory
4. run `ruby convert.rb`
5. enter the date of your ride `dd/mm/yyyy`
6. enter the time of your ride `hh:mm`

Your STAGES{No}.tcx file will be in STAGES/tcx directory and you can upload it to Strava.


next time `ruby convert.rb` command will convert only newly added files to `/original` directory.


