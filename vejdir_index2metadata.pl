#!/usr/local/bin/perl -w
 
#   INITIAL PROGAMMER:  PHH - 20190121
#
#   REVISION :          DESCRIPTION :
#   ----------          ----------------------------------------------
#   20190121
#
#   NAME:               vejdir_index2metadata
#
#   SYNOPSIS:           vejdir_index2metadata 'fil1, fil2,....'
#
#   DESCRIPTION:        Brugt i 2019 til at kon
#                       
#                       
#
#   STIKORD:            CPV
#
#

use strict 'subs';
use strict;
use File::Basename;
use Time::Local;
 
use KX_UTIL::utils;


#my $region = "Aalbaek-Skagen";
#my $lag = "43850";

my $region = "NykoebingF-Sydmotorvejen";
my $lag = "50100";

my $camsn = "Pegasus";

# gps time has 0 at "19800106 00:00:00"
# First we find the UTC time for that moment
my ($dag,$maaned,$aar,$tim,$min,$sec) = (6,1,1980,0,0,0);
my $jan6_1980 = timegm($sec,$min,$tim,$dag,$maaned - 1,$aar - 1900);

# This is the 18 leap seconds after "19800106 00:00:00" got from https://www.ietf.org/timezones/data/leap-seconds.list
# 2571782400	20	# 1 Jul 1981
# 2603318400	21	# 1 Jul 1982
# 2634854400	22	# 1 Jul 1983
# 2698012800	23	# 1 Jul 1985
# 2776982400	24	# 1 Jan 1988
# 2840140800	25	# 1 Jan 1990
# 2871676800	26	# 1 Jan 1991
# 2918937600	27	# 1 Jul 1992
# 2950473600	28	# 1 Jul 1993
# 2982009600	29	# 1 Jul 1994
# 3029443200	30	# 1 Jan 1996
# 3076704000	31	# 1 Jul 1997
# 3124137600	32	# 1 Jan 1999
# 3345062400	33	# 1 Jan 2006
# 3439756800	34	# 1 Jan 2009
# 3550089600	35	# 1 Jul 2012
# 3644697600	36	# 1 Jul 2015
# 3692217600	37	# 1 Jan 2017

my @leap;
# leap1
($dag,$maaned,$aar) = (1,7,1981);
push(@leap,timegm($sec,$min,$tim,$dag,$maaned - 1,$aar - 1900));
# leap2
($dag,$maaned,$aar) = (1,7,1982);
push(@leap,timegm($sec,$min,$tim,$dag,$maaned - 1,$aar - 1900));
# leap3
($dag,$maaned,$aar) = (1,7,1983);
push(@leap,timegm($sec,$min,$tim,$dag,$maaned - 1,$aar - 1900));
# leap4
($dag,$maaned,$aar) = (1,7,1985);
push(@leap,timegm($sec,$min,$tim,$dag,$maaned - 1,$aar - 1900));
# leap5
($dag,$maaned,$aar) = (1,1,1988);
push(@leap,timegm($sec,$min,$tim,$dag,$maaned - 1,$aar - 1900));
# leap6
($dag,$maaned,$aar) = (1,1,1990);
push(@leap,timegm($sec,$min,$tim,$dag,$maaned - 1,$aar - 1900));
# leap7
($dag,$maaned,$aar) = (1,1,1991);
push(@leap,timegm($sec,$min,$tim,$dag,$maaned - 1,$aar - 1900));
# leap8
($dag,$maaned,$aar) = (1,7,1992);
push(@leap,timegm($sec,$min,$tim,$dag,$maaned - 1,$aar - 1900));
# leap9
($dag,$maaned,$aar) = (1,7,1993);
push(@leap,timegm($sec,$min,$tim,$dag,$maaned - 1,$aar - 1900));
# leap10
($dag,$maaned,$aar) = (1,7,1994);
push(@leap,timegm($sec,$min,$tim,$dag,$maaned - 1,$aar - 1900));
# leap11
($dag,$maaned,$aar) = (1,1,1996);
push(@leap,timegm($sec,$min,$tim,$dag,$maaned - 1,$aar - 1900));
# leap12
($dag,$maaned,$aar) = (1,7,1997);
push(@leap,timegm($sec,$min,$tim,$dag,$maaned - 1,$aar - 1900));
# leap13
($dag,$maaned,$aar) = (1,1,1999);
push(@leap,timegm($sec,$min,$tim,$dag,$maaned - 1,$aar - 1900));
# leap14
($dag,$maaned,$aar) = (1,1,2006);
push(@leap,timegm($sec,$min,$tim,$dag,$maaned - 1,$aar - 1900));
# leap15
($dag,$maaned,$aar) = (1,1,2009);
push(@leap,timegm($sec,$min,$tim,$dag,$maaned - 1,$aar - 1900));
# leap16
($dag,$maaned,$aar) = (1,7,2012);
push(@leap,timegm($sec,$min,$tim,$dag,$maaned - 1,$aar - 1900));
# leap17
($dag,$maaned,$aar) = (1,7,2015);
push(@leap,timegm($sec,$min,$tim,$dag,$maaned - 1,$aar - 1900));
# leap18
($dag,$maaned,$aar) = (1,1,2017);
push(@leap,timegm($sec,$min,$tim,$dag,$maaned - 1,$aar - 1900));

# Get a list of files to convert
my @liste = get_files("Angiv input csv","",@ARGV);
exit if (@liste == 0);

# Hver fil i listen gennemsøges.
print "\n";
foreach my $input (@liste) {
    open(CSV,$input) or die "Can't read $input $!\n";
    my @in = <CSV>;
    close(CSV);
    
    (my $output = $input) =~ s/\.csv$/_metadata.csv/;

    print "$input ---> $output\n";
    open(OUT,">$output") or die "can't write $output $!\n";
    print OUT "#0:imgID,1:Uniqe_id,1:camSN,2:lat,3:lon,4:height,5:roll,6:pitch,7:heading,8:AcquisitionTime,9:projectedX,10:projectedY,11:projectedZ,12:Region,13:Roll_Original,14:Pitch_Original\n";
	
	my ($roll,$pitch) = (0,0);
	my ($imgid,$roll_original,$pitch_original,$heading,$lat,$lon,$height,$acquisitiontime,$projectedX,$projectedY,$projectedZ);
	
	# The images from the 2 different tours from Vejdirektoratet have the same names. We insert in the same Superproject in eGIDB, so we need an uniqe id instead of the image name. It is also
	# added to the Metadatamapping file DK_Vejdir_MetadataMapping_CPV_2019.xml
	my $uniqe_id;
	
	if ($in[0] =~ /gps_seconds/) { # Skip the header
		shift(@in);
	}
    foreach my $line (@in) {
        chomp($line);
		my ($gps_seconds,$file_name,$latitude,$longitude,$altitide,$roll_original,$pitch_original,$heading,$projectedX,$projectedY,$projectedZ) = split(' ',$line);
		my $acquisitiontime = convert_gps2utc($gps_seconds);
		$uniqe_id = "$file_name-$lag";
		print OUT "$file_name,$uniqe_id,$camsn,$latitude,$longitude,$altitide,$roll,$pitch,$heading,$acquisitiontime,$projectedX,$projectedY,$projectedZ,$region,$roll_original,$pitch_original\n";
	}
    close(OUT);
}

sub convert_gps2utc {
	my ($gps) = @_;
	# We add the UTC time for "19800106 00:00:00" and sustract the leap seconds. 
	my $tid = $jan6_1980 + $gps;
	foreach my $leap (@leap) {
		if ($tid > $leap) {
			$tid = $tid - 1;
		}
	}
	my @dl = gmtime($tid);
	my $ar = $dl[5] - 100 + 2000;
	my $mon = $dl[4] + 1;
	my $rt = sprintf "%04d-%02d-%02d %02d:%02d:%02d.000000",$ar,$mon,$dl[3],$dl[2],$dl[1],$dl[0];
	return $rt;
}



       