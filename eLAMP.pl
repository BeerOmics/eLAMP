#!/usr/bin/perl



############################### This program is free software; you can redistribute it and/or modify
############################### it under the terms of the GNU General Public License as published by
############################### the Free Software Foundation; either version 2 of the License, or
############################### (at your option) any later version.
############################### 
############################### This program is distributed in the hope that it will be useful,
############################### but WITHOUT ANY WARRANTY; without even the implied warranty of
############################### MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
############################### GNU General Public License for more details.
############################### 
############################### You should have received a copy of the GNU General Public License
############################### along with this program; if not, write to the Free Software
############################### Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
###############################
###############################
###############################
############################### Copyright 2011 Nelson R. Salinas and Damon P. Little



############################### DETERMINE OPTIONS AND ANALYSIS TYPE
my $fasta = ();
my $csv = ();
my $debug = 0;
my $relax = 0;
my $revcom = 0;
### matching percentage of primers
my $mi = 100;
my $mm = 100;
my $mo = 100;
### number of matching nucleotides primers
my $nI = 3;
my $nM = 3;
my $nO = 3;
### distances among primer pairs
my $OAmplicon = 280;
my $IAmplicon = 51;
my $IFtoIR = 1;
my $loop = 25;
### global
my @search = ('echo', '', '|', '', '--show-position');
my $externalFactor = 100000; ### maximum size that can be passed to the external command by IPC::System and sh (varies by system)

for(my $k = 0; $k <= $#ARGV; $k++){
	if($ARGV[$k] eq '-f'){
		if(-e $ARGV[$k+1]){
			$fasta = $ARGV[$k+1];
			}
		}
	if($ARGV[$k] eq '-p'){
		if(-e $ARGV[$k+1]){
			$csv = $ARGV[$k+1];
			}
		}
	if($ARGV[$k] eq '-A'){
		$ARGV[$k+1] =~ tr/[0-9]//cd;
		if(($ARGV[$k+1] > 0) && ($ARGV[$k+1] < 3000)){ ### upper limit is to prevent external command from crashing, 3000 is probably a safe maximum size
			$OAmplicon = $ARGV[$k+1];
			}
		}
	if($ARGV[$k] eq '-a'){
		$ARGV[$k+1] =~ tr/[0-9]//cd;
		if($ARGV[$k+1] > 0){
			$IAmplicon = $ARGV[$k+1];
			}
		}
	if($ARGV[$k] eq '-s'){
		$ARGV[$k+1] =~ tr/[0-9]//cd;
		if($ARGV[$k+1] > 0){
			$IFtoIR = $ARGV[$k+1];
			}
		}
	if($ARGV[$k] eq '-l'){
		$ARGV[$k+1] =~ tr/[0-9]//cd;
		if($ARGV[$k+1] > 0){
			$loop = $ARGV[$k+1];
			}
		}
	if($ARGV[$k] eq '-i'){
		$ARGV[$k+1] =~ tr/[0-9].//cd;
		if(($ARGV[$k+1] > 0) && ($ARGV[$k+1] <= 100)){
			$mi = int($ARGV[$k+1]);
			}
		}
	if($ARGV[$k] eq '-m'){
		$ARGV[$k+1] =~ tr/[0-9].//cd;
		if(($ARGV[$k+1] > 0) && ($ARGV[$k+1] <= 100)){
			$mm = int($ARGV[$k+1]);
			}
		}
	if($ARGV[$k] eq '-o'){
		$ARGV[$k+1] =~ tr/[0-9].//cd;
		if(($ARGV[$k+1] > 0) && ($ARGV[$k+1] <= 100)){
			$mo = int($ARGV[$k+1]);
			}
		}
	if($ARGV[$k] eq '-I'){
		$ARGV[$k+1] =~ tr/[0-9]//cd;
		if(($ARGV[$k+1] > 0) && ($ARGV[$k+1] <= 3)){
			$nI = $ARGV[$k+1];
			}
		}
	if($ARGV[$k] eq '-M'){
		$ARGV[$k+1] =~ tr/[0-9]//cd;
		if(($ARGV[$k+1] > 0) && ($ARGV[$k+1] <= 3)){
			$nM = $ARGV[$k+1];
			}
		}
	if($ARGV[$k] eq '-O'){
		$ARGV[$k+1] =~ tr/[0-9]//cd;
		if(($ARGV[$k+1] > 0) && ($ARGV[$k+1] <= 3)){
			$nO = $ARGV[$k+1];
			}
		}
	if($ARGV[$k] eq '-r'){
		$relax = 1;
		}
	if($ARGV[$k] eq '-c'){
		$revcom = 1;
		}
	if($ARGV[$k] eq '-d'){
		$debug = 1;
		}
	}



if(length($fasta) && length($csv) && ($OAmplicon >= ($IAmplicon + (2 * $loop) + 30)) && ($IAmplicon >= ($IFtoIR + 30))){ ############################### PROPER INPUT GIVEN
	if($debug){
		print(STDERR "script started:\n\t-f = $fasta\n\t-p = $csv\n\t-r = $relax\n\t-c = $revcom\n\t-i = $mi\n\t-m = $mm\n\t-o = $mo\n\t-I = $nI\n\t-M = $nM\n\t-O = $nO\n\t-A = $OAmplicon\n\t-a = $IAmplicon\n\t-s = $IFtoIR\n\t-l = $loop\n\n");		
		}
	
		
		
	############################### FIND AGREP
	my $agrep = ();
	if(($mi != 100) || ($mm != 100) || ($mo != 100) || ($nI != 3) || ($nM != 3) || ($nO != 3)){
		if(length(qx/which tre-agrep/)){
			$agrep = 'tre-agrep';
			} elsif(length(qx/which agrep/)){
				$agrep = 'agrep';
				} else{
					$mi = 100;
					$mm = 100;
					$mo = 100;
					$nI = 3;
					$nM = 3;
					$nO = 3;
					print(STDERR "Approximate matching cannot be used. No 'agrep' or 'tre-agrep' utility found.\nPlease make sure tre-agrep (http://laurikari.net/tre/) is installed and can be\nlocated in \$PATH.\n\n");
					}
		}
	$search[3] = $agrep;

	
				
	###############################	 LOAD EXTERNAL COMMAND (BACKTICKS CANNOT DISTINGUISH BETWEEN CRASH AND NO MATCH)
	use IPC::System::Simple qw(capture $EXITVAL);
	
	
	
	############################### MAKE HASH OF SEQUENCES AND NAMES
	open(INFILE, "<$fasta") or die("Could not open $fasta!\n");
	my $name = ();
	my %sequences = ();
	while(my $line = <INFILE>){
		chomp($line);
		if(length($line)){
			if($line =~ m/^>/){
				$line =~ tr/,/;/;
				$name = substr($line, 1);
				my $x = 1;
				while(exists($sequences{$name})){ ### make name unique
					$name = substr($line, 1) . '[' . $x . ']';
					$x++;
					}
				if($debug && (substr($line, 1) ne $name)){
					print(STDERR 'Duplicate sequence name! ' . substr($line, 1) . " changed to $name\n");	
					}
				} elsif(!length($name) || ($line =~ m/[^ACGTNVDBHWMRKSY\-\ ]/i)){
					die("$fasta is not a valid fasta file (offending line = '$line')\n")
					} else { ### is sequence
						$line = uc($line);
						$line =~ tr/ACGTNVDBHWMRKSY//cd;
						$sequences{$name} .= $line;
						}
			}
		}
	close(INFILE);
	if($revcom){
		my @uSeq = sort(keys(%sequences));
		for(my $k = $#uSeq; $k >= 0; $k--){
			$name = $uSeq[$k] . '[REVERSE COMPLEMENT]';
			my $x = 1;
			while(exists($sequences{$name})){ ### make name unique
				$name = $uSeq[$k] . '[REVERSE COMPLEMENT][' . $x . ']';
				$x++;
				}
			if($debug && ($uSeq[$k] . '[REVERSE COMPLEMENT]' ne $name)){
				print(STDERR 'Duplicate sequence name! ' . $uSeq[$k] . "[REVERSE COMPLEMENT] changed to $name\n");	
				}
			$sequences{$name} = reverse($sequences{$uSeq[$k]});
			$sequences{$name} =~ tr/ACGTNVDBHWMRKSY/TGCANBHVDWKYMSR/;
			}
		}
	if($debug){
		my $buffer = "\nproper fasta file read\n";
		my @uSeq = sort(keys(%sequences));
		for(my $k = $#uSeq; $k >= 0; $k--){
			$buffer .= $uSeq[$k] . ' (' . length($sequences{$uSeq[$k]}) . ' bp): ' . $sequences{$uSeq[$k]} . "\n\n";
			}
		print(STDERR "$buffer\n");
		}

		
	
	############################### MAKE HASH OF UNIQUE SEQUENCES
	my @uSeq = sort(keys(%sequences));
	my %uniqueSequences = ();
	for(my $k = $#uSeq; $k >= 0; $k--){
		$uniqueSequences{$sequences{$uSeq[$k]}} = 0;
		}
	my @uniqSeq = keys(%uniqueSequences);	
	if($debug){
		my $buffer = keys(%uniqueSequences) . " unique sequences:\n";
		my @uSeq = keys(%uniqueSequences);
		my @otherKeys = keys(%sequences);
		for(my $k = $#uSeq; $k >= 0; $k--){
			$buffer .= $uSeq[$k] . ":\n";
			for($j = $#otherKeys; $j >= 0; $j--){
				if($sequences{$otherKeys[$j]} eq $uSeq[$k]){
					$buffer .= $otherKeys[$j] . "\n";
					}	
				}
			$buffer .= "\n\n";
			}
		print(STDERR "$buffer");
		}
	if(keys(%uniqueSequences) <= 0){
		die("No valid sequences read.\n");		
		}
	
			
		
	############################### READ CSV PRIMERS
	my %primers = ();
	my %masterInner = ();
	my %masterMiddle = ();
	my %middle2inner = ();
	my %outer = ();
	my %outer2middle = ();
	open(INFILE, "<$csv") or die("Could not open $csv!\n");
	while(my $line = <INFILE>){
		chomp($line);
		if(length($line)){		
			my @oligos = split(/,/, $line);
			my $pass = 1;
			my $count = 3;
			if(length($oligos[4]) && length($oligos[5])){
				$count = 5;
				}
			for(my $k = $count; $k > 0; $k--){
				if($oligos[$k] =~ m/[^ACGTNVDBHWMRKSY\ \-]/i){
					$pass = 0;
					last;
					}
				$oligos[$k] = uc($oligos[$k]);
				$oligos[$k] =~ tr/ACGTNVDBHWMRKSY//cd;
				if((length($oligos[$k]) < 15) || (length($oligos[$k]) > 25)){
					$pass = 0;
					last;
					} elsif(($relax == 0) && (((($oligos[$k] =~ tr/CGNVDBHMRKSY/CGNVDBHMRKSY/)/length($oligos[$k])) < 0.4) || ((($oligos[$k] =~ tr/CGNVDBHMRKSY/CGNVDBHMRKSY/)/length($oligos[$k])) > 0.65))){
						$pass = 0;
						last;
						}
				}
			if($pass){
				if($count == 5){
					$primers{"$oligos[0]+$oligos[1]|$oligos[2]+$oligos[3]|$oligos[4]+$oligos[5]"} = ();
					$masterInner{"$oligos[0]+$oligos[1]"} = ();
					$masterMiddle{"$oligos[2]+$oligos[3]"} = ();
					push(@{$middle2inner{"$oligos[2]+$oligos[3]"}}, "$oligos[0]+$oligos[1]");
					$outer{"$oligos[4]+$oligos[5]"} = ();
					push(@{$outer2middle{"$oligos[4]+$oligos[5]"}}, "$oligos[2]+$oligos[3]");
					} elsif($count == 3){
						$primers{"$oligos[0]+$oligos[1]|$oligos[2]+$oligos[3]"} = ();
						$masterInner{"$oligos[0]+$oligos[1]"} = ();
						$masterMiddle{"$oligos[2]+$oligos[3]"} = ();
						push(@{$middle2inner{"$oligos[2]+$oligos[3]"}}, "$oligos[0]+$oligos[1]");
						$outer{'x+x'} = ();
						push(@{$outer2middle{'x+x'}}, "$oligos[2]+$oligos[3]");
						}
				}
			}
		}
	close(INFILE);
	if((keys(%masterInner) <= 0) || (keys(%masterMiddle) <= 0)){
		die("No valid primers read. Use '-r' to override primer checking.\n");		
		}
	if($debug){
		my $buffer = keys(%primers) . " primer sets read\n";
		$buffer .=  keys(%masterInner) . " inner primers read\n";
		$buffer .= keys(%masterMiddle) . " middle primers read\n";
		$buffer .= keys(%outer) . " outer primers read\n\n";
		my @sets = keys(%primers);
		for(my $k = 0; $k <= $#sets; $k++){
			$sets[$k] =~ tr/\|/,/;
			$buffer .= 'Set #' . ($k+1) . ' ' . $sets[$k] . "\n\n";
			if(length($buffer) > 10000){
				print(STDERR "$buffer");
				$buffer = ();
				}
			}
		print(STDERR "$buffer\nproper csv file read\n\n");
		}


		
	############################### MAKE RESULT DATA STRUCTURE
	my $output->[0][0]; ### seq x primer
	my %name2number = ();
	for(my $k = 0; $k <= $#uSeq; $k++){
		$output->[$k+1][0] = $uSeq[$k];
		$name2number{$uSeq[$k]} = $k+1;
		}
	my @p = sort(keys(%primers));	
	my %primer2number = ();
	for(my $k = 0; $k <= $#p; $k++){
		$output->[0][$k+1] = $p[$k];
		$primer2number{$p[$k]} = $k+1;
		for(my $j = $#{$output}; $j > 0; $j--){
			$output->[$j][$k+1] = 0;		
			}
		}
	
		
	
	############################### FOR EACH SEQUENCE
	for(my $j = $#uniqSeq; $j >= 0; $j--){
		my %inner = ();		
		my @winner = keys(%masterInner);
		if($debug){
			print(STDERR "\ninner primers:\n");
			}
		for(my $k = $#winner; $k >= 0; $k--){ ############################### FOR EACH INNER PRIMER
			my @result = ();
			(my $forward, my $reverse) = split(/\+/, $winner[$k]);
			$reverse =~ tr/ACGTNVDBHWMRKSY/TGCANBHVDWKYMSR/;
			$reverse = reverse($reverse); 
			my $f = index($uniqSeq[$j], $forward);
			if($f >= 0){ ### exact forward match
				while($f != -1){
					my $amplicon = substr($uniqSeq[$j], ($f+length($forward)), ($IAmplicon - length($forward)));
					my $r = index($amplicon, $reverse, $IFtoIR);
					if($r != -1){ ### exact reverse match
						while($r != -1){
							push(@result, ($f, ($r+$f+length($forward))));  ### "value" of $r modified before push it into @result
							$r = index($amplicon, $reverse, ($r+1));
							}
						}
					$f = index($uniqSeq[$j], $forward, ($f+1));
					}
				if($debug){
					if($#result >= 0){			
						for(my $i = $#uSeq; $i >= 0; $i--){
							if($sequences{$uSeq[$i]} eq $uniqSeq[$j]){ # hash of sequences names
								for(my $q = $#result; $q >= 0; $q -= 2){ 
									print(STDERR "$winner[$k] are exact matches with $uSeq[$i] in F = $result[$q-1] and R = $result[$q] \n\n");
									}
								}
							}
						} else {
							print(STDERR "$winner[$k] have no exact matches\n");
							}
					}
				}
		
			if(($#result == -1) && (($nI != 3) || ($mi != 100))){ ### inexact
				my $ifMatch = int((((100 - $mi)/100) * (length($forward) - 3)) + (3 - $nI));### number of nucleotides available for approximate matching in $forward
				my $irMatch = int((((100 - $mi)/100) * (length($reverse) - 3)) + (3 - $nI));### number of nucleotides available for approximate matching in $reverse
				$search[5] = '"(' . substr($forward,0,(length($forward) - $nI)) . '){ 1i + 1d + 1s < ' . $ifMatch . ' }(' . substr($forward,(length($forward) - $nI)) . '){~0}"';				
				my @F = split(/,/, agrepSearch($uniqSeq[$j], length($forward)));
				if($#F != -1){
					for(my $x = $#F; $x >= 0; $x--){
						my $r = -1 * length($reverse);
						while($r =~ m/[0-9]/){
							my $offset = $r + length($reverse);
							$seq = substr(substr($uniqSeq[$j], $F[$x], $IAmplicon), $offset);
							my $external = "echo '$seq' | $agrep --show-position '(" . substr($reverse,0,$nI) . "){~0}(" . substr($reverse,$nI) . "){ 1i + 1d + 1s < $irMatch }'";
							my @agrepResult = capture([0..1], $external);
							if($EXITVAL == 0){
								($r, my $junk) = split(/\-/, $agrepResult[0]);
								} elsif($EXITVAL == 1){
									$r = ();
									} else {
										die("Cannot run $agrep!");
										}
							if($r =~ m/[0-9]/){
								my $R = $r + $F[$x] + $offset;
								if(($R - $F[$x] - length($forward)) >= $IFtoIR && ($R - $F[$x] + length($reverse)) <= $IAmplicon){	
									push(@result, ($F[$x], $R));
									if($debug){
										for(my $i = $#uSeq; $i >= 0; $i--){
											if($sequences{$uSeq[$i]} eq $uniqSeq[$j]){ # hash of sequences names
												print(STDERR "$winner[$k] are inexact matches with $uSeq[$i] at $F[$x], $R\n\n");
												}
											}
										}
									}
								}
							}
						}
					}
				}
			if($#result != -1){	
				@{$inner{$winner[$k]}} = @result;
				}
			}
		if($debug){
			my @pKey = keys(%masterInner);
			my $buffer = ();
			for(my $k = $#pKey; $k >= 0; $k--){
				$buffer .= 'seq ' . $j . ' ' . $pKey[$k] . ': ';
				if(exists($inner{$pKey[$k]})){
					$buffer .= join(' ', @{$inner{$pKey[$k]}}) . "\n";
					} else {
						$buffer .= "no match\n";
						}
				if(length($buffer) > 10000){
					print(STDERR "$buffer");
					$buffer = ();
					}
				}
			print(STDERR "$buffer");
			}
		
		
		
		############################### FOR EACH MIDDLE PRIMER
		my @wmiddle = ();
		my @prewmiddle = keys(%masterMiddle);
		for(my $k = $#prewmiddle; $k >= 0; $k--){
			for(my $d = $#{$middle2inner{$prewmiddle[$k]}}; $d >= 0; $d--){
				if(exists($inner{$middle2inner{$prewmiddle[$k]}[$d]})){
					push(@wmiddle, 	$prewmiddle[$k]);
					last;
					}
				}
			}	
		my %middle = ();	
		my @prewouter = keys(%outer);	
		if($debug){
			print(STDERR "\nmiddle primers:\ntesting: " . join(', ', @wmiddle) . "\n\n");
			}
		for(my $k = $#wmiddle; $k >= 0; $k--){
			my @result = ();
			(my $forward, my $reverse) = split(/\+/, $wmiddle[$k]);
			$reverse =~ tr/ACGTNVDBHWMRKSY/TGCANBHVDWKYMSR/;
			$reverse = reverse($reverse); 
			my $f = index($uniqSeq[$j], $forward);
			if($f >= 0){ ### exact forward match
				while($f != -1){
					my $amplicon = substr($uniqSeq[$j], ($f+length($forward)+(($loop * 2) + 30 + $IFtoIR)), ($OAmplicon - length($forward) - (($loop * 2) + 30 + $IFtoIR))); ### start at end of F2+25+F1+1+R1+25; length amplicon - everything else
					my $r = index($amplicon, $reverse);
					if($r != -1){ ### exact reverse match
						while($r != -1){
							push(@result, ($f, ($r+$f+length($forward)+(($loop * 2) + 30 + $IFtoIR))));   ### "value" of $r modified before push it into @result
							$r = index($amplicon, $reverse, ($r+1));
							}
						}
					$f = index($uniqSeq[$j], $forward, ($f+1));
					}
				if(($debug) && ($#result >= 0)){			
					for(my $i = $#uSeq; $i >= 0; $i--){
						if($sequences{$uSeq[$i]} eq $uniqSeq[$j]){ # hash of sequences names
							for(my $q = $#result; $q >= 0; $q -= 2){ 
								print(STDERR "$wmiddle[$k] are exact matches with $uSeq[$i] in F = $result[$q-1] and R = $result[$q] \n\n");
								}
							}
						}
					}
				}
		
			if(($#result == -1) && (($nM != 3) || ($mm != 100))){ ### inexact
				my $mfMatch = int((((100 - $mm)/100) * (length($forward) - 3)) + (3 - $nM));### number of nucleotides available for approximate matching in $forward
				my $mrMatch = int((((100 - $mm)/100) * (length($reverse) - 3)) + (3 - $nM));### number of nucleotides available for approximate matching in $reverse
				$search[5] = '"(' . substr($forward,0,(length($forward) - $nM)) . '){ 1i + 1d + 1s < ' . $mfMatch . ' }(' . substr($forward,(length($forward) - $nM)) . '){~0}"';
				my @F = split(/,/, agrepSearch($uniqSeq[$j], length($forward)));
				if($#F != -1){
					for(my $x = $#F; $x >= 0; $x--){
						my $r = -1 * length($reverse);
						while($r =~ m/[0-9]/){
							my $offset = $r + length($reverse);
							my $external = "echo '" . substr(substr($uniqSeq[$j], $F[$x], $OAmplicon), $offset) . "' | $agrep --show-position '(" . substr($reverse, 0, $nM) . "){~0}(" . substr($reverse, $nM) . "){ 1i + 1d + 1s < $mrMatch }'";
							my @agrepResult = capture([0..1], $external);
							if($EXITVAL == 0){
								($r, my $junk) = split(/\-/, $agrepResult[0]);
								} elsif($EXITVAL == 1){
									$r = ();
									} else {
										die("Cannot run $agrep!");
										}
							if($r =~ m/[0-9]/){
								my $R = $r + $F[$x] + $offset;
								if((($R - $F[$x] - length($forward)) >= (($loop * 2) + 30 + $IFtoIR)) && (($R - $F[$x] + length($reverse)) <= $OAmplicon)){
									push(@result, ($F[$x], $R));
									if($debug){
										for(my $i = $#uSeq; $i >= 0; $i--){
											if($sequences{$uSeq[$i]} eq $uniqSeq[$j]){ # hash of sequences names
												print(STDERR "$wmiddle[$k] are inexact matches with $uSeq[$i] at $F[$x], $R[$y]\n\n");
												}
											}
										}
									}
								}
							}
						}
					}
				}

			############################### PROGRESSIVE ELIMINATION
			for(my $d = $#{$middle2inner{$wmiddle[$k]}}; $d >= 0; $d--){
				(my $junk, my $iR) = split(/\+/, $middle2inner{$wmiddle[$k]}[$d]);
				for(my $e = $#result; $e >= 0; $e -= 2){
					for(my $f = $#{$inner{$middle2inner{$wmiddle[$k]}[$d]}}; $f >= 0; $f -= 2){
						if((($result[$e-1]+length($forward)+$loop) <= ($inner{$middle2inner{$wmiddle[$k]}[$d]}[$f-1])) && ($result[$e] >= ($loop+length($iR)+$inner{$middle2inner{$wmiddle[$k]}[$d]}[$f]))){
							for(my $g = $#prewouter; $g >= 0; $g--){
								for(my $h = $#{$outer2middle{$prewouter[$g]}}; $h >= 0; $h--){
									if($outer2middle{$prewouter[$g]}[$h] eq $wmiddle[$k]){
										push(@{$middle{$wmiddle[$k]}}, ($result[$e-1], $result[$e]));
										if($prewouter[$g] eq 'x+x'){
											for(my $z = $#uSeq; $z >= 0; $z--){
												if($uniqSeq[$j] eq $sequences{$uSeq[$z]}){
													$output->[$name2number{$uSeq[$z]}][$primer2number{"$middle2inner{$wmiddle[$k]}[$d]|$wmiddle[$k]"}] = 1;	
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		if($debug){
			my @pKey = keys(%middle);
			my $buffer = ();
			for(my $k = $#pKey; $k >= 0; $k--){
				$buffer .= 'seq ' . $j . ' ' . $pKey[$k] . ': ' . join(' ', @{$middle{$pKey[$k]}}) . "\n";
				if(length($buffer) > 10000){
					print(STDERR "$buffer");
					$buffer = ();
					}
				}	
			print("$buffer");
			}	
		
		
		
		############################### FOR EACH OUTER PRIMER	
		my @wouter = ();
		for(my $k = $#prewouter; $k >= 0; $k--){
			if($prewouter[$k] ne 'x+x'){
				for(my $h = $#{$outer2middle{$prewouter[$k]}}; $h >= 0; $h--){
					if(exists($middle{$outer2middle{$prewouter[$k]}[$h]})){
						push(@wouter, $prewouter[$k]);
						last;
						}
					}
				}
			}
		if($debug){
			print(STDERR "\nouter primers:\ntesting: " . join(', ', @wouter) . "\n\n");
			}
		for(my $k = $#wouter; $k >= 0; $k--){
			my @result = ();
			(my $forward, my $reverse) = split(/\+/, $wouter[$k]);
			$reverse =~ tr/ACGTNVDBHWMRKSY/TGCANBHVDWKYMSR/;
			$reverse = reverse($reverse); 
			my $f = index($uniqSeq[$j], $forward);
			if($f >= 0){ ### exact forward match
				while($f != -1){
					my $amplicon = substr($uniqSeq[$j], ($f+length($forward)+(($loop * 2)+60+$IFtoIR)), (($OAmplicon - (($loop * 2)+60+$IFtoIR)) - length($forward)));
					my $r = index($amplicon, $reverse);
					if($r != -1){ ### exact reverse match
						while($r != -1){
							push(@result, ($f, ($r+$f+length($forward)+(($loop * 2)+60+$IFtoIR))));
							$r = index($amplicon, $reverse, ($r+1));
							}
						}
					$f = index($uniqSeq[$j], $forward, ($f+1));
					}
				if(($debug) && ($#result >= 0)){			
					for(my $i = $#uSeq; $i >= 0; $i--){
						if($sequences{$uSeq[$i]} eq $uniqSeq[$j]){ # hash of sequences names
							for(my $q = $#result; $q >= 0; $q -= 2){ 
								print(STDERR "$wouter[$k] are exact matches with $uSeq[$i] in F = $result[$q-1] and R = $result[$q] \n\n");
								}
							}
						}
					}
				}
		
			if(($#result == -1) && (($nO != 3) || ($mo != 100))){ ### inexact
				my $ofMatch = int((((100 - $mo)/100) * (length($forward) - 3)) + (3 - $nO));### number of nucleotides available for approximate matching in $forward
				my $orMatch = int((((100 - $mo)/100) * (length($reverse) - 3)) + (3 - $nO));### number of nucleotides available for approximate matching in $reverse
				$search[5] = '"(' . substr($forward,0,(length($forward) - $nO)) . '){ 1i + 1d + 1s < ' . $ofMatch . ' }(' . substr($forward,(length($forward) - $nO)) . '){~0}"';
				my @F = split(/,/, agrepSearch($uniqSeq[$j], length($forward)));
				if($#F != -1){
					for(my $x = $#F; $x >= 0; $x--){
						my $r = -1 * length($reverse);
						while($r =~ m/[0-9]/){
							my $offset = $r + length($reverse);
							my $external = "echo '" . substr(substr($uniqSeq[$j], $F[$x], $OAmplicon), $offset) . "' | $agrep --show-position '(" . substr($reverse, 0, $nO) . "){~0}(" . substr($reverse, $nM) . "){ 1i + 1d + 1s < $orMatch }'";
							my @agrepResult = capture([0..1], $external);
							if($EXITVAL == 0){
								($r, my $junk) = split(/\-/, $agrepResult[0]);
								} elsif($EXITVAL == 1){
									$r = ();
									} else {
										die("Cannot run $agrep!");
										}
							if($r =~ m/[0-9]/){
								my $R = $r + $F[$x] + $offset;
								if((($R - $F[$x] - length($forward)) >= (($loop * 2)+60+$IFtoIR)) && (($R - $F[$x] + length($reverse)) <= $OAmplicon)){
									push(@result, ($F[$x], $R));
									if($debug){
										for(my $i = $#uSeq; $i >= 0; $i--){
											if($sequences{$uSeq[$i]} eq $uniqSeq[$j]){ # hash of sequences names
												print(STDERR "$wouter[$k] are inexact matches with $uSeq[$i] at $F[$x], $R\n\n");
												}
											}
										}
									}
								}
							}
						}
					}
				}

			############################### PROGRESSIVE ELIMINATION
			for(my $d = $#{$outer2middle{$wouter[$k]}}; $d >= 0; $d--){
				(my $junk, my $iR) = split(/\+/, $outer2middle{$wouter[$k]}[$d]);
				my $wework = 0;
				for(my $e = $#result; $e >= 0; $e -= 2){
					for(my $f = $#{$middle{$outer2middle{$wouter[$k]}[$d]}}; $f >= 0; $f -= 2){
						if((($result[$e-1]+length($forward)) <= ($middle{$outer2middle{$wouter[$k]}[$d]}[$f-1])) && ($result[$e] >= (length($iR)+$middle{$outer2middle{$wouter[$k]}[$d]}[$f]))){
							$wework = 1;								
							last;
							}
						}
					if($wework){
						last;		
						}
					}
				for($g = $#{$middle2inner{$outer2middle{$wouter[$k]}[$d]}}; $g >= 0; $g--){
					for(my $z = $#uSeq; $z >= 0; $z--){
						if($uniqSeq[$j] eq $sequences{$uSeq[$z]}){
							$output->[$name2number{$uSeq[$z]}][$primer2number{"$middle2inner{$outer2middle{$wouter[$k]}[$d]}[$g]|$outer2middle{$wouter[$k]}[$d]|$wouter[$k]"}] = $wework;
							}
						}
					}
				}
			}
		}


		
		############################### OUTPUT
		my $buffer = ();
		for(my $n = 0; $n <= $#{$output}; $n++){			
			for(my $nn = 0; $nn <= $#{$output->[$n]}; $nn++){			
				$buffer .= $output->[$n][$nn];
				if($nn < $#{$output->[$n]}){
					$buffer .= ',';
					}
				}
			$buffer .= "\n";
			if(length($buffer) > 10000){
				print("$buffer");
				$buffer = ();
				}
			}
		print("$buffer");
		
		
		
		############################### AGREP SEARCH
		sub agrepSearch {
			my $sequence = $_[0];
			my $primerLength = $_[1];	
			my @matches = ();
			my $match = -1 * $primerLength;
			while($match =~ m/[0-9]/){
				my $offset = $match + $primerLength;
				my $seq = substr($sequence, $offset);
				if(length($seq) > $externalFactor){ ### external command crashes with too many bases
					for(my $x = 0; $x <= length($seq); $x += $externalFactor){
						my $length = $externalFactor + $OAmplicon;
						if($length > length($seq)){
							$length = length($seq);
							}
						$search[1] = "'" . substr($seq, $x, $length) . "'";
						my @agrepResult = capture([0..1], join(' ', @search));
						if($EXITVAL == 0){
							($match, my $junk) = split(/\-/, $agrepResult[0]);
							if($match =~ m/[0-9]/){	
								$match += $offset + $x;
								push(@matches, $match);
								last;
								}
							} elsif($EXITVAL == 1){
								$match = ();
								} else {
									die("Cannot run $agrep!");
									}
						}
					} else {
						$search[1] = "'$seq'";
						my @agrepResult = capture([0..1], join(' ', @search));
						if($EXITVAL == 0){
							($match, my $junk) = split(/\-/, $agrepResult[0]);
							if($match =~ m/[0-9]/){	
								$match += $offset + $x;
								push(@matches, $match);
								}
							} elsif($EXITVAL == 1) {
								$match = ();
								} else {
									die("Cannot run $agrep!");
									}
						}
				}
			return(join(',', @matches));			
			}

	
	
			
	} else { ############################### NO INFILES
		print("\nA PERL script for virtual Loop--mediated isothermal AMPlification (LAMP).\n\n");
		print("USAGE: eLAMP.pl -f in-file.fasta -p in-file.csv\n\t\t[-A ###] [-a ###] [-s ##] [-l ##] [-I #] [-M #] [-O #] [-i ###]\n\t\t[-m ###] [-o ###] [-r] [-c]\n");
		print("WHERE:\t-f\tis a fasta formated input file\n");
		print("\t-p\tis a comma separated value (.csv) file containing four or six\n\t\tprimer sequences per line (first six columns; inner forward,\n\t\tinner reverse, middle forward, middle reverse, outer forward,\n\t\touter reverse)\n");
		print("\t-A\tmaximum amplicon size (bp; default = $OAmplicon)\n");
		print("\t-a\tmaximum interloop spacing (bp; default = $IAmplicon)\n");
		print("\t-s\tminimum space between inner primers (bp; default = $IFtoIR)\n");
		print("\t-l\tminimum space between inner and middle primers\n\t\t(bp; default = $loop)\n");
		print("\t-I\tthe number of exact matches at the 3' ends of the inner primer\n\t\tpair (1-3; default = $nI)\n");
		print("\t-M\tthe number of exact matches at the 3' ends of the middle primer\n\t\tpair (1-3; default = $nM)\n");
		print("\t-O\tthe number of exact matches at the 3' ends of the outer primer\n\t\tpair (1-3; default = $nO)\n");
		print("\t-i\tpercent of matching bases for the inner primer pair (excluding\n\t\tthe 3' bases set with -I; default = $mi)\n");
		print("\t-m\tpercent of matching bases for the middle primer pair (excluding\n\t\tthe 3' bases set with -M; default = $mm)\n");
		print("\t-o\tpercent of matching bases for the outer primer pair (excluding\n\t\tthe 3' bases set with -O; default = $mo)\n");
		print("\t-r\tactivate 'relaxed' mode, primer GC content is not checked\n");
		print("\t-c\tevaluate template sequences in both possible orientations\n\n");
		print("This script is distributed under the GNU General Public License.\n\n");
		print("If you use this script, please blame to Salinas and Little.\n\n");
		}
		
		
exit;
