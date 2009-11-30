package Backup::SingleFile;
use 5.008_000; use 5.8.0; 
use warnings;
use strict;

=pod

=encoding utf8

=head1 NAME

Backup::SingleFile - copies one file to a predefined backup-directory, appends the date and a counter for keeping the history.

=head1 EXAMPLE

=over 5

=item
my $ok = File::SimpleBackup::backup_file("MyContacts.txt", "MyBackupDir");

=back

Creates a copy of MyContacts.txt named MyBackupDir/MyContacts_2009-07-19.txt (on the 19th of July 2009)
If the same file copied again on the same day a second copy named MyBackupDir/MyContacts_2009-07-19_000.txt is created.

=head1 TRANSLATIONS

The following documentation is still in German - a short English description can 
be found in the README. 

A first draft translation has been provided by Chuck Butler - it is included in 
the raw-pod text. If you want to help speeding up the translating, please drop 
me an email to <perl at lantschner.name>

=head1 VERSION

Version 0.13

=cut

our $VERSION = '0.13';


=head1 SYNOPSIS

Dieses Modul kopiert eine Datei in ein vordefiniertes Backupverzeichnis. Dabei wir das Datum im ISO-Format (YYYY-MM-DD) angehängt und ggf. durch einen Zähler ergänzt. Im Backup-Verzeichnis vorhandene Sicherungskopien, werden also niemals gelöscht.

=for English_Literal
 This module copies a file in a predefined Backupverzeichnis. Besides, we the date in the ISO format (YYYY-MM-DD) suspended and if necessary with a counter complements. In the Backup list available backup copies, are never extinguished.

This module copies a file into a predefined backup directory. 
Also, we the date in the ISO format (YYYY-MM-DD) appended, and if necessary, a counter is added to the end. 
In the backup directory, the available backup copies are never deleted -or- overwritten.

Typischer Anwendungsfall ist die Erstellung von Sicherungskopien einzelner 
Dateien von z.B. mobilen Geräten auf einen Computer.

=for English_Literal
 Typical application case is the production of backup copies of single files of e.g. mobile devices on a computer.

Typical use for this application is to produce a backup of single files of e.g. 
mobile devices on a computer.

=for German
 Beispiel:

Example:

    use File::SimpleBackup;
	my $src_file = "/Volumes/Garmin/Current.gpx";
	my $sik_dir = "~/MyBackups/Garmin/";

    my $ok = File::SimpleBackup::backup_file($src_file, $sik_dir);
    ...

Dieser Beispiel-Code kopiert am 28. 06. 2008 die Current.gpx eines unter /Volumes/Garmin eingehängten GPS-Gerätes in das 
Verzeichnis MyBackups/Garmin und legt diese dort unter dem Namen Current_2009-06-28.gpx ab. Bei weiteren 
Aufrufen am selben Kalendertag, wird ein Zähler angehängt (Current_2009-06-28_000.gpx, Current_2009-06-28_001.gpx).

=for English_Literal
 This example code copies on 28.06.2008 the Current.gpx one under /Volumes/Garmin hung up GPS device in this 
 List MyBackups/Garmin and files this there under the name Current_2009-06-28.gpx. With other ones 
 To calls in the same calender date, a counter is suspended (Current_2009-06-28_000.gpx, Current_2009-06-28_001.gpx).

=for English_please_improve
This example copies on 28.06.2008, 28 Jun 2008, the file 'Current.gpx' under 
/Volumes/Garmin from the GPS device into this directory  MyBackups/Garmin and 
saves it there under the name 'Current_2009-06-28.gpx'. The following 
calls that are in the same calender date, a counter is appended (Current_2009-06-28_000.gpx, Current_2009-06-28_001.gpx).

=head1 EXPORT

backup - Argumente und Optionen siehe unten

backup - arguments and options see below

append_date - Anhängen des Datums an den Dateinamen (vor die Extension)

append_date - To appendices of the date in the file name (before the extension)

increment - hochzählen des angehängten Zählers bis 999

increment - High-level count of the appended counter to 999 (translation?!?!)

=cut

our @EXPORT_OK = qw( backup append_date increment );
use base qw(Exporter);

=pod

=head1 DEPENDENCIES

Needs the following modules:

=over 4

=item * Carp

=item * File::Basename

=item * Time::localtime

=item * File::Copy

=back

=cut

use Carp;
use File::Basename;
use Time::localtime;
use File::Copy;


#use Smart::Comments '###', '####', '#####' ;
our $DEBUG = 0; #FIXME:

our $EMPTY = q{};
our $SPACE = q{ };
our $BLANK = $SPACE;
our $UNDERSCORE = q{_};
our $DASH = q{-};
our $HASHMARK = q{#};
our @ALLOWED_SEPERATOR = ( $BLANK, $HASHMARK, $DASH, $UNDERSCORE );
our $SEPERATOR = $UNDERSCORE; # default

=head1 FUNCTIONS

=cut

sub backup {

=pod

=head2 backup

Diese Funktion benötigt zwei Parameter:

This function needs two parameters:

src_file: Die zu kopierende Datei. Pfad entweder absolut oder relativ zum Arbeitsverzeichnis.

src_file: The file to be copied. Path either absolutely or relatively to the working directory.

sik_dir: Das Verzeichnis, in dem die Sicherungsdateien abgelegt werden.

sik_dir: The directory in which the backup files are saved.

=head3 OPTIONS

time: UNIX-Time (Epochensekunden) für den Zeitstempel, Voreinstellung ist die aktuelle Systemzeit

=for English_Literal
 time: UNIX time (epoch seconds) for the time stamp, pre-setting are the topical system time

time: UNIX time (epoch seconds) for the time stamp, which is the default setting for system time

seperator: Dateiname und Suffix (Datum bzw. Datum plus Zähler) werden meist durch Leerzeichen oder Underscore getrennt. 
Der Underscore ist die sicherere Wahl, da er auf wohl allen Plattformen akzeptiert wird. Das Leerzeichen 
ist dafür schöner und wird inzwischen in vielen Dateisystemen als gültiges Zeichen in Dateinamen akzeptiert. 
Die Voreinstellung ist aber der Underscore. Zusätzlich werden noch Dash und Hashmark unterstützt.

for English_Literal
 seperator: File name and suffix (date or date plus counter) are mostly separated by blank or Underscore. 
 The Underscore is the more sure choice, because he is accepted on probably all platforms. The blank 
 is nicer for it and is accepted, in the meantime, in many file systems as a valid sign in file names. 
 However, the pre-setting is the Underscore. In addition, Dash and Hashmark are still supported.

seperator: File name and suffix (date or date plus counter) are mostly separated by blank or Underscore. 
The Underscore is the more sure choice, because he is accepted on probably all platforms. The blank 
is nicer for it and is accepted, in the meantime, in many file systems as a valid sign in file names. 
However, the default is the Underscore. In addition, Dash and Hashmark are still supported.

increment_existing: Wenn 1 (wahr), dann werden bei nochmaligem Aufruf am selben Tag weitere Backups angelegt indem 
ein an den Dateinamen angehängter, 3-stelliger Zähler jeweils hoch gezählt wird. So sind insgesamt 1001 Backups je 
Tag möglich (Datei+Datum, Datei+Datum+000, Datei+Datum+001, ... Datei+Datum+999). 
Bei Übergabe einer zu sichernden Datei (src_file) mit dem Suffix 999 wird abgebrochen und ein Fehler ausgegeben.
Ist diese Option 0 oder undef (falsch), kann nur eine Sicherungskopie je Tag angelegt werden. 
Die Voreinstellung ist 1. Siehe auch das Beispiel in SYNOPSIS oben.


increment_existing: If 1 (true), then other Backups are being added by repeated calls during the same day while 
a 3-figure counter appended to the file name in each case is incremented. Thus a maximum of 1001 Backups are possible 
for one day(file Date, File Date 000, file Date 001... File Date 999). 
If called with a file to be backed up (src_file) with the suffix 999 it is terminated, and an error is given.
If this option 0 or undef is (wrong, only one backup copy can be put on day. 
The pre-setting is 1. See the also example in SYNOPSIS on top.

=head3 RETURN VALUE

Die Funktion backup() gibt 1 bei Erfolg und 0 bei Fehlschlag zurück.

The function backup () returns 1 with success and 0 with miss.

=cut

	my $src_file = shift;
	my $sik_dir = shift;
	my $time = shift;
	my $sep = shift;
	my $increment_existing = shift;  
	if (not defined $increment_existing) {
		$increment_existing = 1; # defaults to 1
	}
	
	if (not defined $sep) {
		$SEPERATOR = $UNDERSCORE; # somehow redundant, since already defaults to q{_} in the later called functions
	} elsif (not grep { $_ eq $sep } @ALLOWED_SEPERATOR) {
		print STDERR "The seperator $sep is not allowed! Falling back to default-seperator.\n";
		$SEPERATOR = $UNDERSCORE;
	} else {
		$SEPERATOR = $sep;
	}
	my $today;
	if ($time) {
		$today = localtime $time;
	} else {
		$today = localtime;
	}
	my $iso_date = sprintf('%04d-%02d-%02d', $today->year+1900, $today->mon+1, $today->mday);
	#### iso_date: $iso_date
	$sik_dir =~ s/\/$//; # remove trailing slash
	my($src_name, $src_dir, $src_ext) = fileparse($src_file, qr/\.[^.]*/);
	my $sik_file = "$sik_dir" . q{/} . "$src_name" . "$SEPERATOR" . "$iso_date" . "$src_ext";
	### sik_file: $sik_file

	while ( -e $sik_file and -s $sik_file) {
		if ($increment_existing) {
			$sik_file = increment($sik_file);
			if (not defined $sik_file) {
				print STDERR "Backup aborted: SIK-File not defined\n";
				return 0;
			}
			#### sik_file after increment: $sik_file
		} else {
			carp 'File already exists and is not empty. (May be you should allow increment_existing.)' ;
			return 0;
		}
	}
	### File to be copied: $src_file
	if ( copy($src_file, $sik_file) ) {
		### Backup successfull;
		return 1;
	} else {
		print STDERR "Backup aborted: $!\n";
		return 0;
	}
}

sub append_date {
=pod

=head2 append_date

Diese Funktion hängt an einen als erstes Argument übergebenen Dateinamen das Tagesdatum im ISO-Format an. 
Wird kein zweites Argument übergeben, so verwendet diese Funktion die aktuelle UNIX-Time des Systems, andernfalls
die als zweites Argument übergebene Zeit (UNIX-Time, also Epochensekunden).

This function suspends the day date in the ISO format to a file name handed over as the first argument. 
If no second argument hands over, this function uses the topical UNIX time of the system, otherwise
the time handed over as the second argument (UNIX time, thus epoch seconds).

	$new_filename = append_date("Current.gpx");
	print "$new_filename";
 *-->DE	# gibt am 13. 02. 2009 "Current_2009-02-13.gpx" aus 
        # "Current_2009-02-13.gpx" is returned, when the date is 13 Feb 2009
        
        
	$new_filename = append_date("Current.gpx", 1234567890);
	print "$new_filename";
 *-->DE	# gibt "Current_2009-02-14.gpx" aus - unabhängig vom aktuellen Datum
        # "Current_2009-02-14.gpx" is returned, using the value to over-ride the default system date

Die Erstellung des Strings für das Datum erfolgt passend zur jeweiligen Zeitzone des Systems.

The string for the date is created with respect to the time zone setting of the system.

=head3 VARIABLES

Ist die Variable $SEPERATOR gesetzt, wird das darin gespeicherte Zeichen als Trennzeichen zwischen
Dateiname und Datums-Suffix verwendet. Andernfalls wird der Underscore verwendet.

If the variable $SEPERATOR is set, the sign stored in it becomes as a separator between
File name and data suffix uses. Otherwise the Underscore is used.

	$SEPERATOR = q{_} ==> Current_2009-02-13.gpx  # Underscore
	$SEPERATOR = q{ } ==> Current 2009-02-13.gpx  # Space
	$SEPERATOR = q{#} ==> Current#2009-02-13.gpx  # Hashmark
	$SEPERATOR = q{-} ==> Current-2009-02-13.gpx  # Dash


=head3 RETURN VALUE and ERROR MESSAGES

Die Funktion gibt undef zurück, wenn Fehler aufgetreten sind. 
GGf. werden zuvor noch Fehlermeldungen nach stderr ausgegeben.

The function returns undef if an error has occurred. 
If necessary, an error messages is printed to STDERR.

=cut	

	my $file = shift;
	if ( not defined $file) { return; }
	my $now = shift;

	use Time::localtime;
	my $seperator;
	if ($SEPERATOR) {
		$seperator = $SEPERATOR;
	} else {
		$seperator = $UNDERSCORE;
	}
	my $tm;
	unless ($now) {
		$tm = localtime; 
	} else {
		# check time for appropriate format
		if ($now =~ /\d+/) {
			$tm = localtime($now);
		} else {
			print STDERR "Function append_date expects a unix-time (epoch-seconds) as second argument\n";
			return;
		}
		
	}
	my $iso_date = sprintf '%04d-%02d-%02d', $tm->year+1900, $tm->mon+1, $tm->mday;
	### iso_date: $iso_date
	my($name, $dir, $ext) = fileparse($file, qr/\.[^.]*/);
	### dir: $dir
	### name: $name
	### ext: $ext
	if ($dir eq q{./}) {
		$dir = $EMPTY;
	}
	my $new_file = "$dir" . "$name" . "$seperator" . "$iso_date" . "$ext";
	### sik_file: $new_file
	return "$new_file";
}

sub increment {
=pod

=head2 increment

Diese Funktion hängt an einen als erstes Argument übergebenen Dateinamen einen 3-stelligen Zähler an: 000, 001, ...
Bei der Übergabe von Dateien, deren Namen bereits mit einem solchen Zähler endet, wird der Dateiname mit dem nächst 
höheren Zähler retourniert. Bei Übergabe eines Dateinamens mit 999 am Ende, wird eine Fehlermeldung nach stderr ausgegeben. 
Der Rückgabewert ist in diesem Fall undef.

This function appends a 3-figure counter to a file name handed over as the first argument: 000, 001...
By the handing over of the files whose name already ends with such a counter the file name with becomes afterwards 
higher counter returns. By handing over of a file name with 999 at the end, an error message is given after stderr. 
In this case the return value is undef.

	$new_filename = increment(Current_2009-06-23.gpx);
	print "$new_filename";
 *->DE	# gibt "Current_2009-06-23_000.gpx" aus
 *->LT	# if "Current_2009-06-23_000.gpx" is economical
 	# "Current_2009-06-23_000.gpx" would be the first backup for "Current_2009-06-23.gpx"

	$new_filename = increment(Current_2009-06-23_000.gpx);
	print "$new_filename";
 *->DE	# gibt "Current_2009-06-23_001.gpx" aus
	# "Current_2009-06-23_000.gpx" would be the second backup

	$new_filename = increment(somefile.gpx);
	print "$new_filename";
 *->DE	# gibt "somefile_000.gpx" aus
	# "somefile_000.gpx" would be the first backup for "somefile.gpx"

=cut

	my $file = shift;
	if ( not defined $file) { return; }
	my $sep;
	if ($SEPERATOR) {
		$sep = $SEPERATOR;
	} else {
		$sep = q{_};
	}
	my $counter;
	my $filename_wo_counter; # file-name w/o counter, f.e. 'Current' in Current_001.gpx
	use File::Basename;
    my($filename, $directories, $extension) = fileparse("$file", qr/\.[^.]*/);
	#### filename:     $filename, 
	#### directories:  $directories, 
	#### extension:    $extension
	
	# See if file has already a counter appended
	my $allowed_seperator_regex = qr/$UNDERSCORE|$BLANK|$HASHMARK|$DASH/;
	if ($filename =~ /(.*)$allowed_seperator_regex(\d{3})$/) {
		#### dollar1: $1
		#### dollar2: $2
		$filename_wo_counter = $1;
		$counter = $2;
		$counter =~ s/^(?:$UNDERSCORE|$BLANK|$HASHMARK|$DASH)//; 
		#### counter without seperator: $counter
		if ($counter eq '999') {
			print STDERR "Counter-suffix overrun - only 1001 copies per day supported.\n"; 
			return; 
		}
		$counter++;
		#### counter is now +1: $counter
	} else {
		$counter = "000";
		$filename_wo_counter = $filename; 
	}
	#### counter we append to the filename before returning it: $counter
	if ($directories eq q{./}) {
		$directories = $EMPTY;
	}
	my $new_file = "$directories" . "$filename_wo_counter" . "$sep" . "$counter" . "$extension";
	return $new_file;
}

1; # End of Backup::SingleFile

__END__

=pod

=head1 AUTHOR

Ingo Lantschner, C<< <perl at lantschner.name> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-backup-singlefile at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Backup-SingleFile>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Backup::SingleFile


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Backup-SingleFile>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Backup-SingleFile>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Backup-SingleFile>

=item * Search CPAN

L<http://search.cpan.org/dist/Backup-SingleFile/>

=back


=head1 COPYRIGHT & LICENSE

Copyright 2009 Ingo Lantschner, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut



