package Win32::Process::Memory;

use strict;
use warnings;
use base qw(Exporter);
use vars qw($VERSION @EXPORT @EXPORT_OK);
$VERSION = "0.11";
@EXPORT = qw();
@EXPORT_OK = qw();

require XSLoader;
XSLoader::load('Win32::Process::Memory', $VERSION);

sub new {
	my $class = ref($_[0]) || $_[0] ;
	my $pargs = ref($_[1]) ? $_[1] : {} ;
	my $this = {};
	bless($this, $class);

	# parser access, default is read and write
	my $access = 48;
	if( defined($pargs->{access}) ) {
		$access=16 if $pargs->{access} eq 'read';
		$access=32 if $pargs->{access} eq 'write';
	}

	# get process handle by command line name
	if( defined($pargs->{name}) ) {
		eval 'use Win32::Process::Info;';
		die "Win32::Process::Info is required to get process by name" if $@;
		$pargs->{name} = lc($pargs->{name});
		foreach ( Win32::Process::Info->new( '', 'NT' )->GetProcInfo ) {
			if( lc($_->{Name}) eq $pargs->{name} ) {
				$pargs->{pid} = $_->{ProcessId};
				last;
			}
		}
	}

	# get process handle by pid
	$this->sethandle( OpenByPid($pargs->{pid}, $access) ) if defined($pargs->{pid});

	return $this;
}

sub DESTROY {
	my $this = shift;
	CloseProcess($this->{hProcess}) if defined $this->{hProcess};
}

sub sethandle {
	my $this = shift;
	$this->{hProcess}=$_[0] if $_[0];
}

sub unsethandle {
	my $this = shift;
	undef $this->{hProcess};
}

sub read {
	my $this = shift;
	$_[2] = "" unless defined $_[2];
	defined($this->{hProcess}) ?
		ReadMemory($this->{hProcess}, $_[0], $_[2], $_[1] ) : 0;
}

sub write {
	my $this = shift;
	return 0 unless defined $_[1];
	defined($this->{hProcess}) ?
		ReadMemory($this->{hProcess}, $_[0], $_[1], length($_[1]) ) : 0;
}

1;
__END__

=head1 NAME

Win32::Process::Memory - read and write memory of other windows process

=head1 SYNOPSIS

  require Win32::Process::Memory;
  my ($proc, $buf, $bytes);

  # open process with name = cmd.exe, read-only
  $proc = Win32::Process::Memory->new({ name=>'cmd.exe', access=>'read' });
  # read offset=0x10000 len=256 into $buf, return how much bytes are readed
  $byte=$proc->read(0x10000, 256, $buf);
  # close process
  undef $proc;

  # open process with name = cmd.exe, write-only
  $proc = Win32::Process::Memory->new({ name=>'cmd.exe', access=>'write' });
  # write $buf into offset=0x10000
  $byte=$proc->write(0x10000, $buf);
  # close process
  undef $proc;

  # read and write process with pid = 567
  $proc = Win32::Process::Memory->new({ pid=>567 });
  # read offset=0x10000 len=256 into $buf, return how much bytes are readed
  $byte=$proc->read(0x10000, 256, $buf);
  # write $buf into offset=0x10000
  $byte=$proc->write(0x10000, $buf);
  # close process
  undef $proc;

=head1 DESCRIPTION

read and write memory of other windows process.

=head1 BUGS, REQUESTS, COMMENTS

Please report any requests, suggestions or bugs via
L<http://rt.cpan.org/NoAuth/ReportBug.html?Dist=Win32-Process-Memory>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 Qing-Jie Zhou E<lt>qjzhou@hotmail.comE<gt>

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
