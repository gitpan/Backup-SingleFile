package Backup::SingleFile;
#use 5.010_000; use 5.10.0; # perl 5.10, revision 5 version 10 subversion 0
use 5.008_000; use 5.8.0; 
use warnings;
use strict;

=head1 NAME

Backup::SingleFile - copies one file to a predefined backup-directory, appends the date and a counter for keeping the history.

=head1 EXAMPLE

	my $ok = File::SimpleBackup::backup_file("MyContacts.txt", "MyBackupDir");

Creates a copy of MyContacts.txt named MyBackupDir/MyContacts_2009-07-19.txt (on the 19th of July 2009)

If the same file copied again on the same day a second copy named MyBackupDir/MyContacts_2009-07-19_000.txt is created.
 

=head1 TRANSLATIONS

The following documentation is still in German - a short description can be found in the README. If you want to help speeding up the translating, please drop me an email to <perl at lantschner.name>

=head1 VERSION

Version 0.08

=cut

our $VERSION = '0.08';


=head1 SYNOPSIS

Dieses Modul kopiert eine Datei in ein vordefiniertes Backupverzeichnis. Dabei wir das Datum im ISO-Format (YYYY-MM-DD) angehängt und ggf. durch einen Zähler ergänzt. Im Backup-Verzeichnis vorhandene Sicherungskopien, werden also niemals gelöscht.

Typischer Anwendungsfall ist die Erstellung von Sicherungskopien einzelner Dateien von z.B. mobilen Geräten auf einen Computer.

Beispiel:

    use File::SimpleBackup;
	my $src_file = "/Volumes/Garmin/Current.gpx";
	my $sik_dir = "~/MyBackups/Garmin/";

    my $ok = File::SimpleBackup::backup_file($src_file, $sik_dir);
    ...

Dieser Beispiel-Code kopiert am 28. 06. 2008 die Current.gpx eines unter /Volumes/Garmin eingehängten GPS-Gerätes in das 
Verzeichnis MyBackups/Garmin und legt diese dort unter dem Namen Current_2009-06-28.gpx ab. Bei weiteren 
Aufrufen am selben Kalendertag, wird ein Zähler angehängt (Current_2009-06-28_000.gpx, Current_2009-06-28_001.gpx).

=head1 EXPORT

backup - Argumente und Optionen siehe unten

append_date - Anhängen des Datums an den Dateinamen (vor die Extension)

increment - hochzählen des angehängten Zählers bis 999

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

src_file: Die zu kopierende Datei. Pfad entweder absolut oder relativ zum Arbeitsverzeichnis.

sik_dir: Das Verzeichnis, in dem die Sicherungsdateien abgelegt werden.

=head3 OPTIONEN

time: UNIX-Time (Epochensekunden) für den Zeitstempel, Voreinstellung ist die aktuelle Systemzeit

seperator: Dateiname und Suffix (Datum bzw. Datum plus Zähler) werden meist durch Leerzeichen oder Underscore getrennt. 
Der Underscore ist die sicherere Wahl, da er auf wohl allen Plattformen akzeptiert wird. Das Leerzeichen 
ist dafür schöner und wird inzwischen in vielen Dateisystemen als gültiges Zeichen in Dateinamen akzeptiert. 
Die Voreinstellung ist aber der Underscore. Zusätzlich werden noch Dash und Hashmark unterstützt.

increment_existing: Wenn 1 (wahr), dann werden bei nochmaligem Aufruf am selben Tag weitere Backups angelegt indem 
ein an den Dateinamen angehängter, 3-stelliger Zähler jeweils hoch gezählt wird. So sind insgesamt 1001 Backups je 
Tag möglich (Datei+Datum, Datei+Datum+000, Datei+Datum+001, ... Datei+Datum+999). 
Bei Übergabe einer zu sichernden Datei (src_file) mit dem Suffix 999 wird abgebrochen und ein Fehler ausgegeben.
Ist diese Option 0 oder undef (falsch), kann nur eine Sicherungskopie je Tag angelegt werden. 
Die Voreinstellung ist 1. Siehe auch das Beispiel in SYNOPSIS oben.

=head3 RÜCKGABEWERT

Die Funktion backup() gibt 1 bei Erfolg und 0 bei Fehlschlag zurück.

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

	$new_filename = append_date("Current.gpx");
	print "$new_filename";
	# gibt am 13. 02. 2009 "Current_2009-02-13.gpx" aus 

	$new_filename = append_date("Current.gpx", 1234567890);
	print "$new_filename";
	# gibt "Current_2009-02-14.gpx" aus - unabhängig vom aktuellen Datum

Die Erstellung des Strings für das Datum erfolgt passend zur jeweiligen Zeitzone des Systems.	

=head3 VARIABLES

Ist die Variable $SEPERATOR gesetzt, wird das darin gespeicherte Zeichen als Trennzeichen zwischen
Dateiname und Datums-Suffix verwendet. Andernfalls wird der Underscore verwendet.

	$SEPERATOR = q{_} ==> Current_2009-02-13.gpx  # Underscore
	$SEPERATOR = q{ } ==> Current 2009-02-13.gpx  # Space
	$SEPERATOR = q{#} ==> Current#2009-02-13.gpx  # Hashmark
	$SEPERATOR = q{-} ==> Current-2009-02-13.gpx  # Dash


=head3 RÜCKGABEWERT und FEHLERMELDUNGEN

Die Funktion gibt undef zurück, wenn Fehler aufgetreten sind. 
GGf. werden zuvor noch Fehlermeldungen nach stderr ausgegeben. 

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

	$new_filename = increment(Current_2009-06-23.gpx);
	print "$new_filename";
	# gibt "Current_2009-06-23_000.gpx" aus

	$new_filename = increment(Current_2009-06-23_000.gpx);
	print "$new_filename";
	# gibt "Current_2009-06-23_001.gpx" aus

	$new_filename = increment(somefile.gpx);
	print "$new_filename";
	# gibt "somefile_000.gpx" aus

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



