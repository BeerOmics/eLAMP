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



use Tk;
require Tk::NoteBook;
require Tk::BrowseEntry;
require Tk::Dialog;
require Tk::Pane;


### Main Window
my $mw = MainWindow -> new (-title=>'eLAMP');
my %primers = ();
my %oPrimers= ();
my $prCount = 0;
my $displayPrCount = 1;
my $currPrimer = 0;
my $displayCurrPrimer = 1;
my $mistakes = -1;
my $tabRecord = ();
my $currResult = 0;
my $displayCurrResult = 1;
my $resCount = 0;
my @results = ();
my $displayResCount = 1;
my $amplSeqs = ();
my $deadSeqs = ();
my $semiOutput->[0][0] = ();
my $I = ();
my $M = ();
my $O = ();
my $i = ();
my $m = ();
my $o = ();
my $relax = ();
my $revcom = ();
my $A = ();
my $a = ();
my $s = ();
my $l = ();

my $ufrm = $mw -> Frame(-borderwidth=> 10) -> pack(-fill=>'both');
my $runbut = $ufrm -> Button(-text => 'Run!',-command=> sub{runLAMP();}) -> pack(-side=>'left');
	my $title = 'Electronically Simulated Loop-mediated AMPlification';
	my $label = $ufrm -> Label(-text=>$title) -> pack(-side=>'left', -expand=>1);

my $tabs = $mw -> NoteBook() -> pack(-expand=>1,-fill=>'both');

my $tab1 = $tabs->add('page1', -label=>'Sequence(s)', -raisecmd=>sub{testTab();});

	my $lfrm = $tab1 -> Frame(-borderwidth=> 10) -> pack();
		my $label = $lfrm -> Label(-text=>'Template sequence(s) in FASTA format:')
			-> pack();
		my $template = $lfrm -> Scrolled('Text', -scrollbars => 'oe') -> pack();
	
		$template -> Subwidget('text') -> insert('end', 'Paste the template sequence(s) here.'); ### should disappear on click
		$template -> Subwidget('text') -> configure(-width=>80, -height=>18);
	
	my $rfrm = $tab1 -> Frame(-borderwidth=> 5) -> pack(-expand=>1,-fill=>'both');
		my $but = $rfrm -> Button(-text => 'or select a FASTA file...', -command => sub{openFile();}) -> pack(-side=>'left',-expand=>1); 
		my $sambut = $rfrm -> Button(-text=>'or use sample data', -command => sub{sampleData();}) -> pack(-side=>'left',-expand=>1);
		
my $tab2 = $tabs->add('page2', -label=>'Primers (simple format)', -raisecmd=>sub{testTab();});

	my $bframe = $tab2 -> Frame(-borderwidth=> 10) -> pack(-side=>'bottom',-expand=>1);
		my $prbut = $bframe -> Button (-text=>'or select a primer input file...',-command => sub{openPrimerFile();}) ->pack(-expand=>1);
		
	my $lframe = $tab2 -> Frame() -> pack(-side=>'bottom',-expand=>1);
		my $IF = $lframe -> Entry(-width=>30) -> form(-right=>'%100',-top=>'%0');
		my $IR = $lframe -> Entry(-width=>30) -> form(-right=>'%100',-top=>$IF);
		my $MF = $lframe -> Entry(-width=>30) -> form(-right=>'%100',-top=>$IR);
		my $MR = $lframe -> Entry(-width=>30) -> form(-right=>'%100',-top=>$MF);
		my $OF = $lframe -> Entry(-width=>30) -> form(-right=>'%100',-top=>$MR);
		my $OR = $lframe -> Entry(-width=>30) -> form(-right=>'%100',-top=>$OF);
		
		my $IFlabel = $lframe -> Label(-text=>'Inner forward') -> form(-right=>$IF,-top=>'%0',-bottom=>['&',$IF]); 
		my $IRlabel = $lframe -> Label(-text=>'Inner reverse') -> form(-right=>$IR,-top=>$IFlabel,-bottom=>['&',$IR]);
		my $MFlabel = $lframe -> Label(-text=>'Middle forward') -> form(-right=>$MF,-top=>$IRlabel,-bottom=>['&',$MF]);
		my $MRlabel = $lframe -> Label(-text=>'Middle reverse') -> form(-right=>$MR,-top=>$MFlabel,-bottom=>['&',$MR]);
		my $OFlabel = $lframe -> Label(-text=>'Outer forward') -> form(-right=>$OF,-top=>$MRlabel,-bottom=>['&',$OF]);
		my $ORlabel = $lframe -> Label(-text=>'Outer reverse') -> form(-right=>$OR,-top=>$OFlabel,-bottom=>['&',$OR]);
		
	my $uframe = $tab2 -> Frame() -> pack(-expand=>1);
		my $prevBut = $uframe -> Button (-text=>'Previous',-command=>sub{changeSet(0);}) -> pack(-side=>'left',-expand=>1);
		my $setsLabel = $uframe -> Label(-text=>'Set ') -> pack(-side=>'left',-expand=>1);
		my $currSet = $uframe -> Entry(-width=>5,-textvariable=>\$displayCurrPrimer) ->pack(-side=>'left',-expand=>1);
		my $ofLab = $uframe -> Label(-text=>' of ') -> pack(-side=>'left',-expand=>1);
		my $totSets = $uframe -> Label(-textvariable=>\$displayPrCount) -> pack(-side=>'left',-expand=>1);
		my $nextBut = $uframe -> Button (-text=>'Next',-command=>sub{changeSet(1);}) -> pack(-side=>'left',-expand=>1);

my $tab3 = $tabs->add('page3', -label=>'Primers FIP/BIP(RIP)', -raisecmd=>sub{testTab();});

	my $primersFr = $tab3 -> Frame() -> pack(-side=>'bottom',-expand=>1);
	
		my $R3lab = $primersFr -> Label(-text=>'R3(B3)') -> form(-left=>'%5',-bottom=>'%60');
		my $F3lab = $primersFr -> Label(-text=>'F3') -> form(-left=>'%5',-right=>['&',$R3lab],-bottom=>$R3lab);
		my $RIPlab = $primersFr -> Label(-text=>'RIP(BIP)') -> form(-left=>'%5',-right=>['&',$R3lab],-bottom=>$F3lab);
		my $FIPlab = $primersFr -> Label(-text=>'FIP') -> form(-left=>'%5',-right=>['&',$R3lab],-bottom=>$RIPlab); 
	
		my $FIPentry1 = $primersFr -> Entry(-width=>50) -> form(-left=>$FIPlab,-bottom=>['&',$FIPlab],-top=>['&',$FIPlab]);
		my $RIPentry1 = $primersFr -> Entry(-width=>50) -> form(-left=>$RIPlab,-bottom=>['&',$RIPlab],-top=>$FIPentry1);
		my $F3entry1 = $primersFr -> Entry(-width=>50) -> form(-left=>$F3lab,-bottom=>['&',$F3lab],-top=>$RIPentry1);
		my $R3entry1 = $primersFr -> Entry(-width=>50) -> form(-left=>$R3lab,-bottom=>['&',$R3lab],-top=>$F3entry1);
		my $prtitle = $primersFr -> Label(-text=>'Primer sequence') -> form(-left=>['&',$FIPentry1],-right=>['&',$R3entry1],-bottom=>$FIPentry1);
	
	my $uframe2 = $tab3 -> Frame() -> pack(-expand=>1);
		my $prevBut2 = $uframe2 -> Button (-text=>'Previous',-command=>sub{changeSet(2);}) -> pack(-side=>'left',-expand=>1);
		my $setsLabel2 = $uframe2 -> Label(-text=>'Set ') -> pack(-side=>'left',-expand=>1);
		my $currSet2 = $uframe2 -> Entry(-width=>5,-textvariable=>\$displayCurrPrimer) ->pack(-side=>'left',-expand=>1);
		my $ofLab2 = $uframe2 -> Label(-text=>' of ') -> pack(-side=>'left',-expand=>1);
		my $totSets2 = $uframe2 -> Label(-textvariable=>\$displayPrCount) -> pack(-side=>'left',-expand=>1);
		my $nextBut2 = $uframe2 -> Button (-text=>'Next',-command=>sub{changeSet(3);}) -> pack(-side=>'left',-expand=>1);

my $tab4 = $tabs->add('page4', -label=>'LAMP conditions', -raisecmd=>sub{testTab();});
	my $cenFrame = $tab4 -> Frame () -> pack(-expand=>1);

		my $bigAmplicon = $cenFrame -> Entry (-width=>10) -> form(-left=>'%70',-bottom=>'%100');
		$bigAmplicon -> insert('end','280');
		my $shortAmplicon = $cenFrame -> Entry (-width=>10) -> form(-left=>'%70',-bottom=>$bigAmplicon);
		$shortAmplicon -> insert('end','51');
		my $innerSpace = $cenFrame -> Entry (-width=>10) -> form(-left=>'%70',-bottom=>$shortAmplicon);
		$innerSpace -> insert('end','1');
		my $inner2middle = $cenFrame -> Entry (-width=>10) -> form(-left=>'%70',-bottom=>$innerSpace);
		$inner2middle -> insert('end','25');
	
		my $bigAmpliconL = $cenFrame -> Label(-text=>'Maximum amplicon size (bp)')-> form(-right=>$bigAmplicon,-bottom=>['&',$bigAmplicon]);
		my $shortAmpliconL = $cenFrame -> Label(-text=>'Maximum interloop spacing (bp)')-> form(-right=>$shortAmplicon,-bottom=>['&',$shortAmplicon]);
		my $innerSpaceL = $cenFrame -> Label(-text=>'Minimum space between inner primers (bp)')-> form(-right=>$innerSpace,-bottom=>['&',$innerSpace]);
		my $inner2middleL = $cenFrame -> Label(-text=>'Minimum space between inner and middle primers (bp)')-> form(-right=>$inner2middle,-bottom=>['&',$inner2middle]);

		my $rc = $cenFrame -> Checkbutton(-text=>'Evaluate template sequences in both possible orientations',-onvalue=>'-c',-offvalue=>'',-variable=>\$revcom) -> form(-left=>'%11',-bottom=>'%62',-pady=> 7);
		my $relaxB = $cenFrame -> Checkbutton(-text=>'Do not verify primer GC content',-onvalue=>'-r',-offvalue=>'',-variable=>\$relax) -> form(-left=>'%28',-bottom=>$rc,-pady=> 7);
		my $OLabel = $cenFrame -> Label(-text=>'Outer pair') -> form(-right=>'%30',-bottom=>'%33');
		my $MLabel = $cenFrame -> Label(-text=>'Middle pair') -> form(-right=>'%30',-bottom=>$OLabel,-right=>['&',$OLabel]);
		my $ILabel = $cenFrame -> Label(-text=>'Inner pair') -> form(-right=>'%30',-bottom=>$MLabel,-right=>['&',$MLabel]);
		

		my $oenm = $cenFrame -> Entry (-width=>10) -> form(-left=>$OLabel,-top=>['&',$OLabel],-bottom=>['&',$OLabel],-padx=> 35);
		$oenm -> insert('end','3');
		my $menm = $cenFrame -> Entry (-width=>10) ->form(-left=>$MLabel,-top=>['&',$MLabel],-bottom=>$oenm,-padx=> 35);
		$menm -> insert('end','3');
		my $ienm = $cenFrame -> Entry (-width=>10) ->form(-left=>$ILabel,-top=>['&',$ILabel],-bottom=>$menm,-padx=> 35);
		$ienm -> insert('end','3');
		my $label10 = $cenFrame -> Label(-text=>"Nucleotides for\nexact matching") -> form(-left=>['&',$ienm],-right=>['&',$ienm],-bottom=>$ienm); 

		my $oanm = $cenFrame -> Entry (-width=>5) ->form(-left=>'%70',-top=>['&',$oenm],-bottom=>['&',$oenm]);
		$oanm -> insert('end','100');
		my $manm = $cenFrame -> Entry (-width=>5) ->form(-left=>['&',$oanm],-top=>['&',$menm],-bottom=>$oanm);
		$manm -> insert('end','100');
		my $ianm = $cenFrame -> Entry (-width=>5, -validate=>'key',-validatecommand=>sub{$_[1] =~ /\d/},-invalidcommand=>sub{$tab4->bell})
			->form(-left=>['&',$manm],-top=>['&',$ienm],-bottom=>$manm);
		$ianm -> insert('end','100');
		my $label9 = $cenFrame -> Label(-text=>"Approximate\nmatching") -> form(-left=>'%67',-bottom=>$ianm);
		
		my $oPer = $cenFrame -> Label(-text=>'%') -> form(-left=>$oanm,-top=>['&',$oanm],-bottom=>['&',$oanm]);
		my $mPer = $cenFrame -> Label(-text=>'%') -> form(-left=>$manm,-top=>['&',$manm],-bottom=>$oPer);
		my $iPer = $cenFrame -> Label(-text=>'%') -> form(-left=>$ianm,-top=>['&',$ianm],-bottom=>$mPer);

		
		
my $tab5 = $tabs->add('page5', -label=>'Results', -raisecmd=>sub{testTab();});
	my $resultTabs = $tab5 -> NoteBook() -> pack(-expand=>1,-fill=>'both');
	my $resTab1 = $resultTabs->add('page1', -label=>'Simple format');
		
		my $resultsFr1 = $resTab1 -> Frame() -> pack(-side=>'top',-expand=>1, -fill=>'both');
			my $resultsFr111 = $resultsFr1 -> Frame() -> form(-left=>'%12',-right=>'%60',-top=>'%0',-bottom=>'%100');
				my $prevBut3 = $resultsFr111 -> Button (-text=>'Previous', -command=>sub{changeResults(0);}) -> pack(-side=>'left');
				my $setsLabel3 = $resultsFr111 -> Label(-text=>'Set ') -> pack(-side=>'left');
				my $currSet3 = $resultsFr111 -> Entry(-width=>5,-textvariable=>\$displayCurrResult) ->pack(-side=>'left');
				my $ofLab3 = $resultsFr111 -> Label(-text=>' of ') -> pack(-side=>'left');
				my $totSets3 = $resultsFr111 -> Label(-textvariable=>\$displayResCount) -> pack(-side=>'left');
				my $nextBut3 = $resultsFr111 -> Button (-text=>'Next', -command=>sub{changeResults(1);}) -> pack(-side=>'left');

			my $resultsFr112 = $resultsFr1 -> Frame() -> form(-left=>'%58',-right=>'%100',-top=>'%0',-bottom=>'%100');
				my @seqOption = ('amplified target', 'failed to amplify');
				my $seqDisplay = 'amplified target';
				for(my $x = 0; $x <= $#seqOption; $x++){
					$resultsFr112 -> Radiobutton(-text=>$seqOption[$x], -variable=>\$seqDisplay, -value=>$seqOption[$x],-command=>sub{showAmpl();}) -> pack(-side=>'left',-fill=>'both');
					}

		my $resultsFr3 = $resTab1 -> Frame() -> pack(-side=>'right',-expand=>1, -fill=>'both', -pady=>8, -padx=>5);
			my $pane = $resultsFr3 -> Scrolled('Text', -scrollbars=>'oe', -state=>'disable')->pack(-expand=>1, -fill=>'both');
			$pane->Subwidget('text')->configure(-relief=>'ridge', -width=>35, -height=>15);
			
		my $resultsFr4 = $resTab1 -> Frame() -> pack(-side=>'bottom',-expand=>1);
			my $resultbut = $resultsFr4 -> Button(-text=>'Save results to .csv file...',-command=>sub{saveFile();}) -> pack();
			my $savedresultbut = $resultsFr4 -> Button(-text=>'Load saved results from .csv file...',-command=>sub{openSavedFile();}) -> pack(-pady=>'5');
			
		my $resultsFr2 = $resTab1 -> Frame() -> pack(-side=>'left',-expand=>1);
			
			my $IFr = $resultsFr2 -> Entry(-width=>30, -state=>'disable') -> form(-right=>'%100',-top=>'%0');
			my $IRr = $resultsFr2 -> Entry(-width=>30, -state=>'disable') -> form(-right=>'%100',-top=>$IFr);
			my $MFr = $resultsFr2 -> Entry(-width=>30, -state=>'disable') -> form(-right=>'%100',-top=>$IRr);
			my $MRr = $resultsFr2 -> Entry(-width=>30, -state=>'disable') -> form(-right=>'%100',-top=>$MFr);
			my $OFr = $resultsFr2 -> Entry(-width=>30, -state=>'disable') -> form(-right=>'%100',-top=>$MRr);
			my $ORr = $resultsFr2 -> Entry(-width=>30, -state=>'disable') -> form(-right=>'%100',-top=>$OFr);
			
			my $IFlabelr = $resultsFr2 -> Label(-text=>'Inner forward') -> form(-right=>$IFr,-top=>'%0',-bottom=>['&',$IFr]); 
			my $IRlabelr = $resultsFr2 -> Label(-text=>'Inner reverse') -> form(-right=>$IRr,-top=>$IFlabelr,-bottom=>['&',$IRr]);
			my $MFlabelr = $resultsFr2 -> Label(-text=>'Middle forward') -> form(-right=>$MFr,-top=>$IRlabelr,-bottom=>['&',$MFr]);
			my $MRlabelr = $resultsFr2 -> Label(-text=>'Middle reverse') -> form(-right=>$MRr,-top=>$MFlabelr,-bottom=>['&',$MRr]);
			my $OFlabelr = $resultsFr2 -> Label(-text=>'Outer forward') -> form(-right=>$OFr,-top=>$MRlabelr,-bottom=>['&',$OFr]);
			my $ORlabelr = $resultsFr2 -> Label(-text=>'Outer reverse') -> form(-right=>$ORr,-top=>$OFlabelr,-bottom=>['&',$ORr]);
	
	my $resTab2 = $resultTabs->add('page2', -label=>'FIP/RIP format');

		my $resultsFr13 = $resTab2 -> Frame() -> pack(-side=>'top',-fill=>'both',-expand=>1);
			my $resultsFr131 = $resultsFr13 -> Frame() -> form(-left=>'%17',-right=>'%60',-top=>'%0',-bottom=>'%100');
				my $prevBut4 = $resultsFr131 -> Button (-text=>'Previous', -command=>sub{changeResults(2);}) -> pack(-side=>'left');
				my $setsLabel4 = $resultsFr131 -> Label(-text=>'Set ') -> pack(-side=>'left');
				my $currSet4 = $resultsFr131 -> Entry(-width=>5,-textvariable=>\$displayCurrResult) -> pack(-side=>'left');
				my $ofLab4 = $resultsFr131 -> Label(-text=>' of ') -> pack(-side=>'left');
				my $totSets4 = $resultsFr131 -> Label(-textvariable=>\$displayResCount) -> pack(-side=>'left');
				my $nextBut4 = $resultsFr131 -> Button (-text=>'Next', -command=>sub{changeResults(3);}) -> pack(-side=>'left');

			my $resultsFr132 = $resultsFr13 -> Frame() -> form(-left=>'%64',-right=>'%100',-top=>'%0',-bottom=>'%100');
				my @seqOption2 = ('amplified target', 'failed to amplify');
				my $seqDisplay2 = 'amplified target';
				for(my $x = 0; $x <= $#seqOption2; $x++){
					$resultsFr132 -> Radiobutton(-text=>$seqOption2[$x], -variable=>\$seqDisplay2, -value=>$seqOption2[$x],-command=>sub{showAmpl();}) -> pack(-side=>'left',-fill=>'both');
					}
	
		my $resultsFr11 = $resTab2 -> Frame() -> pack(-side=>'right',-expand=>1, -fill=>'both', -pady=>8, -padx=>5);
			my $pane2 = $resultsFr11 -> Scrolled('Text', -scrollbars=>'oe')->pack(-expand=>1, -fill=>'both');
			$pane2->Subwidget('text')->configure(-relief=>'ridge', -width=>35, -height=>15);

		my $resultsFr12 = $resTab2 -> Frame() -> pack(-side=>'bottom');
			my $resultbut2 = $resultsFr12 -> Button(-text=>'Save results to .csv file...',-command=>sub{saveFile();}) -> pack();
			my $savedresultbut2 = $resultsFr12 -> Button(-text=>'Load saved results from .csv file...',-command=>sub{openSavedFile();}) -> pack(-pady=>'15');
		
		my $resultsFr14 = $resTab2 -> Frame() -> pack(-side=>'bottom',-expand=> 1);
			my $R3labr = $resultsFr14 -> Label(-text=>'R3(B3)') -> form(-left=>'%5',-bottom=>'%85');
			my $F3labr = $resultsFr14 -> Label(-text=>'F3') -> form(-left=>'%5',-right=>['&',$R3labr],-bottom=>$R3labr);
			my $RIPlabr = $resultsFr14 -> Label(-text=>'RIP(BIP)') -> form(-left=>'%5',-right=>['&',$R3labr],-bottom=>$F3labr);
			my $FIPlabr = $resultsFr14 -> Label(-text=>'FIP') -> form(-left=>'%5',-right=>['&',$R3labr],-bottom=>$RIPlabr); 
		
			my $FIPentryr = $resultsFr14 -> Entry(-width=>50, -state=>'disable') -> form(-left=>$FIPlabr,-bottom=>['&',$FIPlabr],-top=>['&',$FIPlabr]);
			my $RIPentryr = $resultsFr14 -> Entry(-width=>50, -state=>'disable') -> form(-left=>$RIPlabr,-bottom=>['&',$RIPlabr],-top=>$FIPentryr);
			my $F3entryr = $resultsFr14 -> Entry(-width=>50, -state=>'disable') -> form(-left=>$F3labr,-bottom=>['&',$F3labr],-top=>$RIPentryr);
			my $R3entryr = $resultsFr14 -> Entry(-width=>50, -state=>'disable') -> form(-left=>$R3labr,-bottom=>['&',$R3labr],-top=>$F3entryr);
			my $prtitler = $resultsFr14 -> Label(-text=>'Primer sequence') -> form(-left=>['&',$FIPentryr],-right=>['&',$R3entryr],-bottom=>$FIPentryr);

$mw -> resizable(0,0);

		
sub changeResults{
	my $direction = $_[0];	
	
	if((($direction == 0) || ($direction == 2)) && ($currResult <= 0)){
		return(0);
		}
		
	if((($direction == 1) || ($direction == 3)) && ($currResult == $resCount)){
		return(0);
		}

	$IFr -> configure(-state=>'normal');
	$IRr -> configure(-state=>'normal');
	$MFr -> configure(-state=>'normal');
	$MRr -> configure(-state=>'normal');;
	$OFr -> configure(-state=>'normal');
	$ORr -> configure(-state=>'normal');
	$FIPentryr -> configure(-state=>'normal');
	$RIPentryr -> configure(-state=>'normal');
	$F3entryr -> configure(-state=>'normal');
	$R3entryr -> configure(-state=>'normal');

	$IFr -> delete('0.0','end'); 
	$IRr -> delete('0.0','end');
	$MFr -> delete('0.0','end');
	$MRr -> delete('0.0','end');
	$OFr -> delete('0.0','end');
	$ORr -> delete('0.0','end');
	$FIPentryr -> delete('0.0','end');
	$RIPentryr -> delete('0.0','end');
	$F3entryr -> delete('0.0','end');
	$R3entryr -> delete('0.0','end');
	$pane -> Subwidget('scrolled') -> delete('0.0','end');
	$pane2 -> Subwidget('scrolled') -> delete('0.0','end');

	if(($direction == 1) || ($direction == 3)){
		if($currResult < $resCount){
			$currResult++;
			$displayCurrResult++;
			$IFr -> insert('end',$oPrimers{$currResult}[0]); 
			$IRr -> insert('end',$oPrimers{$currResult}[1]);
			$MFr -> insert('end',$oPrimers{$currResult}[2]);
			$MRr -> insert('end',$oPrimers{$currResult}[3]);
			$OFr -> insert('end',$oPrimers{$currResult}[4]);
			$ORr -> insert('end',$oPrimers{$currResult}[5]);
			$FIPentryr -> insert('end', rc($oPrimers{$currResult}[0]) . '-TTTTT-' . $oPrimers{$currResult}[2]);
			$RIPentryr -> insert('end', rc($oPrimers{$currResult}[1]) . '-TTTTT-' . $oPrimers{$currResult}[3]);
			$F3entryr -> insert('end', $oPrimers{$currResult}[4]);
			$R3entryr -> insert('end', $oPrimers{$currResult}[5]);
			&showSeqs;
			}
		}

	if(($direction == 0) || ($direction == 2)){
		$currResult--;
		$displayCurrResult--;
			$IFr -> insert('end',$oPrimers{$currResult}[0]); 
			$IRr -> insert('end',$oPrimers{$currResult}[1]);
			$MFr -> insert('end',$oPrimers{$currResult}[2]);
			$MRr -> insert('end',$oPrimers{$currResult}[3]);
			$OFr -> insert('end',$oPrimers{$currResult}[4]);
			$ORr -> insert('end',$oPrimers{$currResult}[5]);
			$FIPentryr -> insert('end', rc($oPrimers{$currResult}[0]) . '-TTTTT-' . $oPrimers{$currResult}[2]);
			$RIPentryr -> insert('end', rc($oPrimers{$currResult}[1]) . '-TTTTT-' . $oPrimers{$currResult}[3]);
			$F3entryr -> insert('end', $oPrimers{$currResult}[4]);
			$R3entryr -> insert('end', $oPrimers{$currResult}[5]);
			&showSeqs;
		}
	$IFr -> configure(-state=>'disable', -disabledforeground=>'black');
	$IRr -> configure(-state=>'disable', -disabledforeground=>'black');
	$MFr -> configure(-state=>'disable', -disabledforeground=>'black');
	$MRr -> configure(-state=>'disable', -disabledforeground=>'black');;
	$OFr -> configure(-state=>'disable', -disabledforeground=>'black');
	$ORr -> configure(-state=>'disable', -disabledforeground=>'black');
	$FIPentryr -> configure(-state=>'disable', -disabledforeground=>'black');
	$RIPentryr -> configure(-state=>'disable', -disabledforeground=>'black');
	$F3entryr -> configure(-state=>'disable', -disabledforeground=>'black');
	$R3entryr -> configure(-state=>'disable', -disabledforeground=>'black');
	return(0);
	}

sub changeSet{
	my $direction = $_[0];

	if((($direction == 0) || ($direction == 2)) && ($currPrimer <= 0)){
		return(0);
		}

	my @oligo = ();
	my @pauci = ();
	my $FIPe = ();
	my $RIPe = ();
	my @FIP = ();
	my @RIP = ();
	
	if(($direction == 0) || ($direction == 1)|| ($direction == 4)){ ### Get information from entries
		$oligo[0] =  uc($IF -> get());
		$oligo[1] =  uc($IR -> get());
		$oligo[2] =  uc($MF -> get());
		$oligo[3] =  uc($MR -> get());
		$oligo[4] =  uc($OF -> get());
		$oligo[5] =  uc($OR -> get());
		}

	if(($direction == 2) || ($direction == 3)|| ($direction == 5)){ ### Get information from entries
		$FIPe = $FIPentry1 -> get();
		$RIPe = $RIPentry1 -> get();
		if((($FIPe =~ tr/-/-/) == 2) || (!length($FIPe))){
			if((($RIPe =~ tr/-/-/) == 2) || (!length($RIPe))){
				@FIP = split(/\-/, $FIPe);
				@RIP = split(/\-/, $RIPe);
				$pauci[0] = rc(uc($FIP[0]));
				$pauci[1] = rc(uc($RIP[0]));
				$pauci[2] = uc($FIP[2]);
				$pauci[3] = uc($RIP[2]);
				$pauci[4] = uc($F3entry1 -> get());
				$pauci[5] = uc($R3entry1 -> get());
				} else {
					&weirdPrimer($RIPe, 1, $direction);
					return(0);
					}
			} else {
				&weirdPrimer($FIPe, 0, $direction);
				return(0);
				}
		}

	for(my $l = 5; $l >= 0; $l--){ ### Check if primers are modified versions of previously stored sets
		if(($direction == 0) || ($direction == 1) || ($direction == 4)){ ### New / modified primers in the F1-F2 tab
			if($oligo[$l] ne $primers{$currPrimer}[$l]){
				my $fail = 0;
				if(!length($oligo[0]) && !length($oligo[1]) && !length($oligo[2]) && !length($oligo[3]) && !length($oligo[4]) && !length($oligo[5])){
					my $error = $mw->Dialog(-title => 'Warning',
					-text => "This primer set is emty.\nDo you want to delete this set from memory?",
					-default_button=>'No', -buttons=>['Yes', 'No']) -> Show();
					if($error eq 'Yes'){
						for(my $h = $currPrimer; $h < $prCount; $h++){
							@{$primers{$h}} = @{$primers{$h+1}};
							}
						@{$primers{$prCount}} = ();
						$prCount--;
						$displayPrCount--;
						if($currPrimer > $prCount){
							$currPrimer--;
							$displayCurrPrimer--;
							}
						$IF -> insert('end',$primers{$currPrimer}[0]); 
						$IR -> insert('end',$primers{$currPrimer}[1]);
						$MF -> insert('end',$primers{$currPrimer}[2]);
						$MR -> insert('end',$primers{$currPrimer}[3]);
						$OF -> insert('end',$primers{$currPrimer}[4]);
						$OR -> insert('end',$primers{$currPrimer}[5]);
						return(0);
						}elsif($error eq 'No'){
							$IF -> insert('end',$primers{$currPrimer}[0]); 
							$IR -> insert('end',$primers{$currPrimer}[1]);
							$MF -> insert('end',$primers{$currPrimer}[2]);
							$MR -> insert('end',$primers{$currPrimer}[3]);
							$OF -> insert('end',$primers{$currPrimer}[4]);
							$OR -> insert('end',$primers{$currPrimer}[5]);
							return(0);
							}
					}elsif(length($oligo[5]) || length($oligo[4])){
						for(my $q = 5; $q >= 0; $q--){
							if(test($oligo[$q])){
								$fail = 1;
								&weirdPrimer($oligo[$q], $q, $direction);
								return(0);
								}
							}
						}elsif(length($oligo[3])){
							for(my $q = 3; $q >= 0; $q--){
								if(test($oligo[$q])){
									$fail = 1;
									&weirdPrimer($oligo[$q], $q, $direction);
									return(0);
									}
								}
							}else{
								$fail = 1;
								&weirdPrimer($oligo[3], 3, , $direction);
								return(0);
								}
				if($fail == 0){
					@{$primers{$currPrimer}} = @oligo;
					$mistakes = -1;
					}
				last;
				}
			} elsif(($direction == 2) || ($direction == 3) || ($direction == 5)){ ### New / modified primers in the FIP/RIP tab
				if($pauci[$l] ne $primers{$currPrimer}[$l]){
					my $fail = 0;
					if(!length($pauci[0]) && !length($pauci[1]) && !length($pauci[2]) && !length($pauci[3]) && !length($pauci[4]) && !length($pauci[5])){
						my $error = $mw->Dialog(-title => 'Warning',
						-text => "This primer set is emty.\nDo you want to delete this set from memory?",
						-default_button=>'No', -buttons=>['Yes', 'No']) -> Show();
						if($error eq 'Yes'){
							for(my $h = $currPrimer; $h < $prCount; $h++){
								@{$primers{$h}} = @{$primers{$h+1}};
								}
							@{$primers{$prCount}} = ();
							$prCount--;
							$displayPrCount--;
							if($currPrimer > $prCount){
								$currPrimer--;
								$displayCurrPrimer--;
								}
							if(!length($primers{$currPrimer}[0])){
								$FIPentry1 -> delete('0.0','end');
								$RIPentry1 -> delete('0.0','end');
								$F3entry1 -> delete('0.0','end');
								$R3entry1 -> delete('0.0','end');
								}else{
									$FIPentry1 -> insert('end', rc($primers{$currPrimer}[0]) . '-TTTTT-' . $primers{$currPrimer}[2]);
									$RIPentry1 -> insert('end', rc($primers{$currPrimer}[1]) . '-TTTTT-' . $primers{$currPrimer}[3]);
									$F3entry1 -> insert('end', $primers{$currPrimer}[4]);
									$R3entry1 -> insert('end', $primers{$currPrimer}[5]);
									}
							return(0);
							}elsif($error eq 'No'){
								$FIPentry1 -> insert('end', rc($primers{$currPrimer}[0]) . '-TTTTT-' . $primers{$currPrimer}[2]);
								$RIPentry1 -> insert('end', rc($primers{$currPrimer}[1]) . '-TTTTT-' . $primers{$currPrimer}[3]);
								$F3entry1 -> insert('end', $primers{$currPrimer}[4]);
								$R3entry1 -> insert('end', $primers{$currPrimer}[5]);
								return(0);
								}
						}elsif(length($pauci[5])){
							for(my $q = 5; $q >= 0; $q--){
								if(test($pauci[$q])){
									$fail = 1;
									&weirdPrimer($pauci[$q], $q, $direction);
									return(0);								
									}
								}
							}elsif(length($pauci[3])){
								for(my $q = 3; $q >= 0; $q--){
									if(test($pauci[$q])){
										$fail = 1;
										&weirdPrimer($pauci[$q], $q, $direction);
										return(0);
										}
									}
								}else{
									$fail = 1;
									}
					if($fail == 0){
						@{$primers{$currPrimer}} = @pauci;
						$mistakes = -1;
						}		
					last;
					}
				}
		}
	if(($direction != 4) && ($direction != 5)){
		$IF -> delete('0.0','end');
		$IR -> delete('0.0','end');
		$MF -> delete('0.0','end');
		$MR -> delete('0.0','end');
		$OF -> delete('0.0','end');
		$OR -> delete('0.0','end');
		$FIPentry1 -> delete('0.0','end');
		$RIPentry1 -> delete('0.0','end');
		$F3entry1 -> delete('0.0','end');
		$R3entry1 -> delete('0.0','end');
		}
	if(($direction == 1) || ($direction == 3)){
		if($currPrimer < $prCount){
			$currPrimer++;
			$displayCurrPrimer++;
			if(length($primers{$currPrimer}[0]) && length($primers{$currPrimer}[1]) && length($primers{$currPrimer}[2]) && length($primers{$currPrimer}[3])){
				$IF -> insert('end',$primers{$currPrimer}[0]); 
				$IR -> insert('end',$primers{$currPrimer}[1]);
				$MF -> insert('end',$primers{$currPrimer}[2]);
				$MR -> insert('end',$primers{$currPrimer}[3]);
				$OF -> insert('end',$primers{$currPrimer}[4]);
				$OR -> insert('end',$primers{$currPrimer}[5]);
				$FIPentry1 -> insert('end', rc($primers{$currPrimer}[0]) . '-TTTTT-' . $primers{$currPrimer}[2]);
				$RIPentry1 -> insert('end', rc($primers{$currPrimer}[1]) . '-TTTTT-' . $primers{$currPrimer}[3]);
				$F3entry1 -> insert('end', $primers{$currPrimer}[4]);
				$R3entry1 -> insert('end', $primers{$currPrimer}[5]);
				}
			}elsif($currPrimer == $prCount){
				if(length($primers{$currPrimer}[0]) && length($primers{$currPrimer}[1]) && length($primers{$currPrimer}[2]) && length($primers{$currPrimer}[3])){
					$currPrimer++;
					$displayCurrPrimer++;
					$prCount++;
					$displayPrCount++;
					}
				}
		}

	if(($direction == 0) || ($direction == 2)){
		$currPrimer--;
		$displayCurrPrimer--;
		if(length($primers{$currPrimer}[0]) && length($primers{$currPrimer}[1]) && length($primers{$currPrimer}[2]) && length($primers{$currPrimer}[3])){
			$IF -> insert('end',$primers{$currPrimer}[0]); 
			$IR -> insert('end',$primers{$currPrimer}[1]);
			$MF -> insert('end',$primers{$currPrimer}[2]);
			$MR -> insert('end',$primers{$currPrimer}[3]);
			$OF -> insert('end',$primers{$currPrimer}[4]);
			$OR -> insert('end',$primers{$currPrimer}[5]);
			$FIPentry1 -> insert('end', rc($primers{$currPrimer}[0]) . '-TTTTT-' . $primers{$currPrimer}[2]);
			$RIPentry1 -> insert('end', rc($primers{$currPrimer}[1]) . '-TTTTT-' . $primers{$currPrimer}[3]);
			$F3entry1 -> insert('end', $primers{$currPrimer}[4]);
			$R3entry1 -> insert('end', $primers{$currPrimer}[5]);
			}
		}

	return(0);
	}
	
sub openFile { ### user will select file to open
	my $ffile = $mw -> getOpenFile ();
	return(sequenceData(File::Spec->rel2abs($ffile)));
	}
	
sub openPrimerFile { ### user will select file to open
	%primers = ();
	$currPrimer = 0;
	$displayCurrPrimer = 1;
	$prCount = -1;
	$displayPrCount = 0;
	open(INFILE, '<', $mw -> getOpenFile()) or die("Could not open primer file\n");
	while(my $line = <INFILE>){
		chomp($line);
		$line = uc($line);
		$line =~ tr/ACGTNVDBHWMRKSY,\-//cd;
		if(length($line)){
			my @oligo = ();
			my @bits = split(/,/, $line);
			if(($line =~ m/\-/) && length($bits[7])){ ### F1,R1,F2,R2,F3,R3,F1c-TTTT-F2,R1c-TTTT-R2
				$oligo[0] = $bits[0];
				$oligo[1] = $bits[1];
				$oligo[2] = $bits[2];
				$oligo[3] = $bits[3];
				$oligo[4] = $bits[4];
				$oligo[5] = $bits[5];
				} elsif(($line =~ m/\-/) && length($bits[5])){ ### F1,R1,F2,R2,F1c-TTTT-F2,R1c-TTTT-R2
					$oligo[0] = $bits[0];
					$oligo[1] = $bits[1];
					$oligo[2] = $bits[2];
					$oligo[3] = $bits[3];
					} elsif(($line =~ m/\-/) && length($bits[3])){ ### F3,R3,F1c-TTTT-F2,R1c-TTTT-R2 or F1c-TTTT-F2,R1c-TTTT-R2,F3,R3
						if($bits[0] =~ m/\-/){
							my @tidbits = split(/-/, $bits[0]);
							$oligo[0] = rc($tidbits[0]);
							$oligo[1] = $tidbits[2];
							@tidbits = split(/-/, $bits[1]);
							$oligo[2] = rc($tidbits[0]);
							$oligo[3] = $tidbits[2];
							$oligo[4] = $bits[2];
							$oligo[5] = $bits[3];
							}else{
								my @tidbits = split(/-/, $bits[2]);
								$oligo[0] = rc($tidbits[0]);
								$oligo[1] = $tidbits[2];
								@tidbits = split(/-/, $bits[3]);
								$oligo[2] = rc($tidbits[0]);
								$oligo[3] = $tidbits[2];
								$oligo[4] = $bits[0];
								$oligo[5] = $bits[1];
								}
						} elsif(($line =~ m/\-/) && length($bits[1])){  ### F1c-TTTT-F2,R1c-TTTT-R2
							my @tidbits = split(/-/, $bits[0]);
							$oligo[0] = rc($tidbits[0]);
							$oligo[1] = $tidbits[2];
							@tidbits = split(/-/, $bits[1]);
							$oligo[2] = rc($tidbits[0]);
							$oligo[3] = $tidbits[2];
							} elsif($line !~ m/\-/){ ### F1,R1,F2,R2 or F1,R1,F2,R2,F3,R3
								my @bits = split(/,/, $line);
								$oligo[0] = $bits[0];
								$oligo[1] = $bits[1];
								$oligo[2] = $bits[2];
								$oligo[3] = $bits[3];
								$oligo[4] = $bits[4];
								$oligo[5] = $bits[5];
								}
			my $fail = 0;
			for(my $q = $#oligo; $q >= 0; $q--){ ### check each primer
				if(length($oligo[$q])){
					if(test($oligo[$q])){
						$fail = 1;			
						last;
						}
					}
				}
			if((!$fail) && length($oligo[0]) && length($oligo[1]) && length($oligo[2]) && length($oligo[3])){
				$prCount++;	
				$displayPrCount++;
				@{$primers{$prCount}} = @oligo;
				}
			}
		}
	close(INFILE);

	sub test($){
		my $primer = uc($_[0]);
		if(length($primer)){
			if($primer =~ m/[^ACGTNVDBHWMRKSY\-]/){
				return(1);
				}
			if(($relax ne '-r') && ((($primer =~ tr/CGNVDBHMRKSY/CGNVDBHMRKSY/)/length($primer)) < 0.4) || ((($primer =~ tr/CGNVDBHMRKSY/CGNVDBHMRKSY/)/length($primer)) > 0.65) || (length($primer) < 15) || (length($primer) > 25)){
				return(1);
				} else {
					return(0);
					}
			} else {
				return(1);
			}
		}

	sub rc($){
		my $primer = uc($_[0]);
		$primer =~ tr/ACGTNVDBHWMRKSY/TGCANBHVDWKYMSR/;
		return(reverse($primer)); 
		}

	$IF -> delete('0.0','end');
	$IF -> insert('end',$primers{0}[0]); 
	$IR -> delete('0.0','end');
	$IR -> insert('end',$primers{0}[1]);
	$MF -> delete('0.0','end');
	$MF -> insert('end',$primers{0}[2]);
	$MR -> delete('0.0','end');
	$MR -> insert('end',$primers{0}[3]);
	$OF -> delete('0.0','end');
	$OF -> insert('end',$primers{0}[4]);
	$OR -> delete('0.0','end');
	$OR -> insert('end',$primers{0}[5]);

	$FIPentry1 -> delete('0.0','end');
	my $FIP = rc($primers{0}[0]) . 'TTTTT' . $primers{0}[2];
	$FIPentry1 -> insert('end', $FIP);
	$RIPentry1 -> delete('0.0','end');
	my $RIP = rc($primers{0}[1]) . 'TTTTT' . $primers{0}[3];
	$RIPentry1 -> insert('end', $RIP);
	$F3entry1 -> delete('0.0','end');
	$F3entry1 -> insert('end',$primers{0}[4]);
	$R3entry1 -> delete('0.0','end');
	$R3entry1 -> insert('end',$primers{0}[5]);

	return(0);
	}

sub openSavedFile{
	my $file = $mw -> getOpenFile();
	if(-e $file){
		runLAMP($file);
		}
	return(0);
	}
	
sub runLAMP {
	my $infile = $_[0];

	if(length($oPrimers{0}[0])){
		my $error = $mw->Dialog(-title => 'Warning',
		-text => "Current results will be cleared from memory.\nDo you want to save them before continuing?",
		-default_button=>'Yes', -buttons=>['Yes', 'No', 'Cancel']) -> Show();
		if($error eq 'Yes'){
			&saveFile;
			}elsif($error eq 'Cancel'){
				return(0);
				}
		}
	%oPrimers = ();
	$amplSeqs = ();
	$deadSeqs = ();
	$currResult = 0;
	$displayCurrResult = 1;
	$resCount = 0;
	@results = ();
	$displayResCount = 1;
	for(my $k = $#{$semiOutput}; $k >= 0; $k--){
		for(my $j = $#{$semiOutput->[$k]}; $j >= 0; $j--){
			$semiOutput->[$k][$j] = ();
			}
		}
	my $name = ();
	my %sequences = ();
	my $fastaBuffer = ();
	my $csvBuffer= ();
	my $inputSeq = $template -> Subwidget('text') -> get('0.0','end');
	my @sirrpem = ();
	
	if(-e $infile){
		open(INFILE, '<', $infile) or die("Could not open saved results file\n");
		my @savedResults = ();
		my $x = 0;
		my $k = 0;
		while(my $line = <INFILE>){
			chomp($line);
			if(length($line)){
				my @bits = split(/,/, $line);
				if($k == 0){
					$x = $#bits;
					if($x < 1){
						my $bigError = $mw->Dialog(-title => 'A simple mistake',-text => 'Saved results file is invalid.') -> Show();
						return(0);
						}
					for(my $j = $#bits; $j > 0; $j--){
						my @tidbits = split(/\+|\|/, $bits[$j]);
						for(my $i = $#tidbits; $i >= 0; $i--){
							if(test($tidbits[$i])){
								my $bigError = $mw->Dialog(-title => 'A simple mistake',-text => 'Saved results file is invalid.') -> Show();
								return(0);
								}
							}
						}
					push(@savedResults, $line);
					} else {
						if($#bits != $x){
							my $bigError = $mw->Dialog(-title => 'A simple mistake',-text => 'Saved results file is invalid.') -> Show();
							return(0);
							}
						if(join('', @bits[1..$#bits]) =~ m/[^01]/){
							my $bigError = $mw->Dialog(-title => 'A simple mistake',-text => 'Saved results file is invalid.') -> Show();
							return(0);
							}
						if($line =~ m/,,/){
							my $bigError = $mw->Dialog(-title => 'A simple mistake',-text => 'Saved results file is invalid.') -> Show();
							return(0);
							}
						push(@savedResults, $line);
						}
				$k++;
				}
			}
		close(INFILE);
		@results = @savedResults;
		undef(@savedResults);
		} else {
			&changeSet(1);
			&changeSet(3);
			&testConditions;
	
			if(!exists($primers{0}) && !length($inputSeq)){
				my $error = $mw->Dialog(-title => 'A simple mistake',
				-text => 'If you want results, you must provide a template sequence and primers.') -> Show();
				return(0);
				} elsif(!exists($primers{0})){
					my $error = $mw->Dialog(-title => 'A simple mistake',
					-text => 'If you want results, you must provide primers.') -> Show();
					return(0);
					} elsif(!length($inputSeq)){
						my $error = $mw->Dialog(-title => 'A simple mistake',
						-text => 'If you want results, you must provide a template sequence.') -> Show();
						return(0);
						}

			### test and edit a fasta file from template sequences window
			my @line = split("\n", $inputSeq);
			for(my $y = 0; $y <= $#line; $y++){
				if(length($line[$y])){
					if($line[$y] =~ m/^>/){
						$line[$y] =~ tr/,/;/;
						$name = $line[$y];
						my $x = 1;
						while(length($sequences{$name})){ ### make name unique
							$name = $line[$y] . '_[' . $x . ']';
							$x++;
							}
						if($line[$y] ne $name){
							my $error = $mw->Dialog(-title => 'A simple mistake',-text => "Duplicate sequence name! $line changed to $name.") -> Show();
							}
						} elsif(($line[$y] eq'Paste the template sequence(s) here.') && !$#line){
							my $bigError = $mw->Dialog(-title => 'A simple mistake',-text => 'If you want results, you must provide a template sequence.') -> Show();
							return(0);					
							} elsif(!length($name) || ($line[$y] =~ m/[^ACGTNVDBHWMRKSY\-\ ]/i)){
								my $z = $y+1;
								my $bigError = $mw->Dialog(-title => 'A simple mistake',-text => "Input sequences are not valid fasta format (line $z = $line[$y]).") -> Show();
								return(0);
								} else { ### is sequence
									$line[$y] = uc($line[$y]);
									$line[$y] =~ tr/ACGTNVDBHWMRKSY//cd;
									$sequences{$name} .= $line[$y];
									}
					}
				}
			$inputSeq = ();
			my @seqKey = keys(%sequences);
			open(FILE, '>temporary-input-file-for-eLAMP.fasta') or die $!;
			for(my $t = $#seqKey; $t >= 0; $t--){
				$fastaBuffer .= $seqKey[$t];
				my @seq = split(//, $sequences{$seqKey[$t]});
				for(my $u = 0; $u <= $#seq; $u++){
					if($u % 80){
						$fastaBuffer .= $seq[$u];
						} else {
							$fastaBuffer .= "\n" . $seq[$u];
							}
					}
				$fastaBuffer .= "\n";
				if(length($fastaBuffer) > 10000){
					print FILE $fastaBuffer;
					$fastaBuffer = ();
					}
				}
			print FILE $fastaBuffer;
			$fastaBuffer = ();
			%sequences = ();
			close(FILE);
	
			### make a csv file from primers sets
			my @primerKey = keys(%primers);
			open(FILE, '>temporary-input-file-for-eLAMP.csv') or die $!;
			for(my $e = 0; $e <= $#primerKey; $e++){
				$csvBuffer .= join(',', @{$primers{$e}}) . "\n";
				if(length($csvBuffer) > 10000){
					print FILE $csvBuffer;
					$csvBuffer = ();
					}
				}
			print FILE $csvBuffer;
			close(FILE);
			$csvBuffer = ();
	
			### run eLAMP
			my $eLAMP = ();
			if(-e 'eLAMP.pl'){
				$eLAMP = './eLAMP.pl';
				} elsif(length(qx/which eLAMP.pl/)){
					$eLAMP = 'eLAMP.pl';
					}
			if(length($eLAMP)){
				@results = split("\n", qx/$eLAMP -f temporary-input-file-for-eLAMP.fasta -p temporary-input-file-for-eLAMP.csv -I $I -M $M -O $O -i $i -m $m -o $o -A $A -a $a -s $s -l $l $relax $revcom/);
				} else {
					my $bigError = $mw->Dialog(-title => 'A simple mistake',-text => "eLAMP.pl cannot be found!") -> Show();
					}
	
			unlink('temporary-input-file-for-eLAMP.fasta');
			unlink('temporary-input-file-for-eLAMP.csv');
			}

	### feed results tab with the output from eLAMP
	for(my $y = $#results; $y >= 0; $y--){
		my @cell = split(/,/, $results[$y]);
		for(my $x = $#cell; $x >= 0; $x--){
			$semiOutput->[$y][$x] = $cell[$x];
			}
		}
	for(my $p = 1; $p <= $#{$semiOutput->[0]}; $p++){
		my @setti = split(/\|/, $semiOutput->[0][$p]);
		for(my $r = 0; $r <= $#setti; $r++){
			push(@{$oPrimers{$p - 1}}, (split(/\+/, $setti[$r])));
			}
		}
	$resCount = (keys(%oPrimers) - 1);
	$displayResCount = ($resCount + 1);
	$currResult = 0;
	$displayCurrResult = 1;

	$IFr -> configure(-state=>'normal');
	$IRr -> configure(-state=>'normal');
	$MFr -> configure(-state=>'normal');
	$MRr -> configure(-state=>'normal');;
	$OFr -> configure(-state=>'normal');
	$ORr -> configure(-state=>'normal');
	$FIPentryr -> configure(-state=>'normal');
	$RIPentryr -> configure(-state=>'normal');
	$F3entryr -> configure(-state=>'normal');
	$R3entryr -> configure(-state=>'normal');

	$IFr -> delete('0.0','end');
	$IRr -> delete('0.0','end');
	$MFr -> delete('0.0','end');
	$MRr -> delete('0.0','end');;
	$OFr -> delete('0.0','end');
	$ORr -> delete('0.0','end');
	$FIPentryr -> delete('0.0','end');
	$RIPentryr -> delete('0.0','end');
	$F3entryr -> delete('0.0','end');
	$R3entryr -> delete('0.0','end');
	
	$IFr -> insert('end',$oPrimers{0}[0]);
	$IRr -> insert('end',$oPrimers{0}[1]);
	$MFr -> insert('end',$oPrimers{0}[2]);
	$MRr -> insert('end',$oPrimers{0}[3]);
	$OFr -> insert('end',$oPrimers{0}[4]);
	$ORr -> insert('end',$oPrimers{0}[5]);
	$FIPentryr -> insert('end', rc($oPrimers{0}[0]) . '-TTTTT-' . $oPrimers{0}[2]);
	$RIPentryr -> insert('end', rc($oPrimers{0}[1]) . '-TTTTT-' . $oPrimers{0}[3]);
	$F3entryr -> insert('end', $oPrimers{0}[4]);
	$R3entryr -> insert('end', $oPrimers{0}[5]);
	
	$IFr -> configure(-state=>'disable', -disabledforeground=>'black');
	$IRr -> configure(-state=>'disable', -disabledforeground=>'black');
	$MFr -> configure(-state=>'disable', -disabledforeground=>'black');
	$MRr -> configure(-state=>'disable', -disabledforeground=>'black');;
	$OFr -> configure(-state=>'disable', -disabledforeground=>'black');
	$ORr -> configure(-state=>'disable', -disabledforeground=>'black');
	$FIPentryr -> configure(-state=>'disable', -disabledforeground=>'black');
	$RIPentryr -> configure(-state=>'disable', -disabledforeground=>'black');
	$F3entryr -> configure(-state=>'disable', -disabledforeground=>'black');
	$R3entryr -> configure(-state=>'disable', -disabledforeground=>'black');

	&showSeqs;
	$tabs->raise('page5');
	return(0);
	}

sub sampleData {
	$template -> Subwidget('text') -> delete('0.0','end');
	$template -> Subwidget('text') -> insert('end', '>Pseudoselaginella_primula
TCCAAACGGGGAAGGGCTTGCGGTGGATACCTAGGCACCCAGGGACGAAGAAGGGCGTAGCAAGCGACAATG 
CTTCGGGAAGCCAGAGATAAGCATAGATCCGGAGATCCCCGAATGGGTTAACCCCTTGAAGAACTGCCGAAT 
CCGTGGGATGGGGCAAGAGACAACCTGGCAAACCGAAACATCCAAATAGCCGGGGGAAGAGAAAGCAAAAGC 
GATTCCCGTAGTAGCGGCGAGCGAAGAGGGAGTAGCCTAAACCGTGGGAACGGGGTTGTGGGAGAGCAATAA 
GTATAAGGTTGTGCTGCTAGGTGAAGCGGTCGAGTCCCGCATCCCAGACGGTTAGAGTCCGGTAGCCGGAAG 
CAGCACAGGCTGACGCTCCGACCCGAGTAGCATGGGGCACGTGGAATCCCGTGCGAATCAGCGAGGACCACC 
TCGTAAGGCTAAATACTTCTGGGTGACCGATAGCGAAATAGTACCGTGAGGGAAAGGTGAAAAGAACCCCCA 
CCAGGGAGTGAAATAGAACATGAAACCGTAAGCTCCCGAGCAGTGGGAGGATAATTGGATATCTGACCGCGT 
GCCTGTTGAAGAATGAGCCGGCGACTTATAGGCGGCGGCCTGGTTAAGGAAACCCACCGGAGCCGTAGCGAA 
AGCGAGTCTTCCCAGGGGCAACTGTCGCTGCTTATGGACCCGAACCCGGGTGATCTATCCATGACCAGGATG 
AAGCTTGGATGAAACTAGGTGGAGGTCCGAACCGACTGATGTTGAAAAATCAGCGGATGAGTCGTGGTTAGG 
GGTGAAATGCCACTCGAACCCGGAGCTAGCTGGTTCTCCCCGAAATGCGTTGCTACCTGACTGTTACGGACT
GTTACGGTGCGGAATGCGAGAGGCTGCGAGAGCGTTAGGGGTAAAGCCCAAACCGGGGCAAACTCTGAATAC
TAGGTATGACCCCCGAGTAACACGGTTGCTAAGGGTCAGCCAGTGAGACGGTGGACCGGACCGGGGGATAAG
CTTCACTTCACTTCACCGTCGAGGAAACAGGGAAACAGCGAAACCCGGATCACCTAAAGGAGGTAGGAGTGC 
AAAGACAGCCGGGAGGTTTGCCCAGAAGCAGCCACCCTTGAAAGAGTGCGTAATAGCTCACTGATCAAGCGC 
TCCTGCGCCGAGGATGAACGGGACTAAGCGGTCTGCCGAAGCTGTGGGATGTCGAAAAACACATCGGTAGGG 
GAGCGTTCCGCCGCCTCGGAAGGAGGAAGCACCAGCGCGAGCAGGTGCGGACGAAGCGGAAGCGAGAATGTC 
GGCTTGAGTAACGCAAACATTGGTGAGAATCCAATGCCCCGAAAACCCAAGGGTTCCTCCGCAAGGTTCGTC 
CACGGAGGGTGAGTCAGGGCCTAAGATCAGGCCGATAGGCGTAGTCGATGGACAACAGGCGAATATTCCTGT 
ACTACCCATCGTTGGTCACGGGGGACGGAGGAGGCCAGGTTAGCCGAAAGATGGTTATCGGTTCAAGGGCGC 
AAAGTGAGTGAACCTTTCGGGGCGATGATAAGGGGTAGAGAGAATGCCTCGAGCCAACGCCCGAGTAGCAGG 
CGCTACGGCGCTGAAGTAACTCATGCCACACTCCCAAGAAAAGCCCGAACGACCTTCAACGAGTGGGTACCT 
GTACCTGAAACCGACACAGGTAGGTAGGTAGAGAATACCTAGGGGCGCGAGACAACTCTCTCTAAGGAACTC 
GGCAAAATAGCCCCGCAACTTCGGGAGAAGGGGCGCCTTCTCGCAGAGGAGGTCGCAGTGACCAGGCCCAGG 
CGACTGTTTACCAAAAACACAGGTCTCCGCAAAGTCGTAAGACCATGTATGGGGGCTGACGCCTGCCCAGTG 
CCGGGAGGTGAAGGAAGTTGGTGACCTGATGACAGGAAAGCTAGCGACCGAAGCCCCGGTGAACGGCGGCCG 
TAACTATAACGGTCCTAAGGTAGCGAAATTCCTTGTCGGGTAAGTTCCGACCCGCACGAAAGGCGTAACGAT 
CTGGGCACTGTCTCGGAGAGAGACTCGGTGAAATAGACATGTCTGTGAAGATGCGGACTACCCGCACCCGGA 
CAGAAAGACCCTATGAAGCTTTACTGTTCCCTGAGATTGGCTTTGGGCTCTTCCTGCGCAGCTTAGGTGGAA 
GGCGAGGAAGGTCCTCTTTCGGGGGGGCTCGAGCCATCAGTGAAATACCACTCTAGGAGAGCCAAAATTCTC 
ACTTTGCGGCGTCACTCACGGGCCAAGGGACAGTCTCAGGTAGACAGTTTCTATGGGGCGTAGGCCTCCCAA 
AGGGTAACGGAGGCGCGCAAAGGTTCCCTCGGGCTGGACGGAAATCAGCCTTCAAGTGCAAAGGCGGAAGGG 
AGCTCGACTGCAAGACCCACCCGTCGAGCAGGGACGAAAGTCGGCCTTAGTGATCCGACGGTGCCGGGTGGA 
AGGGCCGTCGCTCAACGGATAAAAGTTACTCTAGGGATAACAGGCTGATCTTCCCCAAGAGTTCACATCGAC 
GGGAAGGTTTGGCACCTCGATGTCGGCTCTTCGCCACCTGGGGCGGTAGTACGTTCCAAGGGTTGGGCTGTT 
CGCCCATCAAAGCGGTACGTGAGCTGGGTTCAGAACGTCGTGAGACAGTTCGGTCCATATCCGGTGCGGGCG 
TTGGAGCATTGATAGGACCTTCCCCTAGTACGAGAGGACCGGGAAGGACGCACCTCCGGTGTACCAGTTATC 
GTGCCCGCGGTACACGCTGGGTAGCCAAGTGCGGAGCGGATAACTGCTGAAAGCATCTAAGCAGGAAGCCCA 
CCCAAAGATGAGTGCTCCCCT

>Pseudoselaginella_secunda
TCCAAACGGGGAAGGGCTTGCGGTGGATACCTAGGCACCCAGGGACGAAGAAGGGCGTAGCAAGCGACAATG 
CTTCGGGAAGCCAGAGATAAGCATAGATCCGGAGATCCCCGAATGGGTTAACCCCTTGAAGAACTGCCGAAT 
CCGTGGGATGGGGCAAGAGACAACCTGGCAAACCGAAACATCCAAATAGCCGGGGGAAGAGAAAGCAAAAGC 
GATTCCCGTAGTAGCGGCGAGCGAAGAGGGAGTAGCCTAAACCGTGGGAACGGGGTTGTGGGAGAGCAATAA 
GTATAAGGTTGTGCTGCTAGGTGAAGCGGTCGAGTCCCGCATCCCAGACGGTTAGAGTCCGGTAGCCGGAAG 
CAGCACAGGCTGACGCTCCGACCCGAGTAGCATGGGGCACGTGGAATCCCGTGCGAATCAGCGAGGACCACC 
TCGTAAGGCTAAATACTTCTGGGTGACCGATAGCGAAATAGTACCGTGAGGGAAAGGTGAAAAGAACCCCCA 
CCAGGGAGTGAAATAGAACATGAAACCGTAAGCTCCCGAGCAGTGGGAGGATAATTGGATATCTGACCGCGT 
GCCTGTTGAAGAATGAGCCGGCGACTTATAGGCGGCGGCCTGGTTAAGGAAACCCACCGGAGCCGTAGCGAA 
AGCGAGTCTTCCCAGGGGCAACTGTCGCTGCTTATGGACCCGAACCCGGGTGATCTATCCATGACCAGGATG 
AAGCTTGGATGAAACTAGGTGGAGGTCCGAACCGACTGATGTTGAAAAATCAGCGGATGAGTCGTGGTTAGG 
GGTGAAATGCCACTCGAACCCGGAGCTAGCTGGTTCTCCCCCTATGAGGCGCAGCGATTGGCTACCTGAGGT
TACCTGAGGTTAACTAGCTGGTTCCGGTGCGGGCTGCGAGAGCGGTACCAAACCGGGGCAAACTCTGAATAC
CTCTGAATACTAGGTATGACCCCCGAGTAACACGGTTGCTAAGGGTCAGCCAGTGAGACGGTGGACGGGAAA
CAGCCAGTATCACCAGCTAAGGCCCGGACCGGGGCCTAAATGACCGCTCAGTGGTAAAGGAGGTAGGAGTGC 
AAAGACAGCCGGGAGGTTTGCCCAGAAGCAGCCACCCTTGAAAGAGTGCGTAATAGCTCACTGATCAAGCGC 
TCCTGCGCCGAGGATGAACGGGACTAAGCGGTCTGCCGAAGCTGTGGGATGTCGAAAAACACATCGGTAGGG 
GAGCGTTCCGCCGCCTCGGAAGGAGGAAGCACCAGCGCGAGCAGGTGCGGACGAAGCGGAAGCGAGAATGTC 
GGCTTGAGTAACGCAAACATTGGTGAGAATCCAATGCCCCGAAAACCCAAGGGTTCCTCCGCAAGGTTCGTC 
CACGGAGGGTGAGTCAGGGCCTAAGATCAGGCCGATAGGCGTAGTCGATGGACAACAGGCGAATATTCCTGT 
ACTACCCATCGTTGGTCACGGGGGACGGAGGAGGCCAGGTTAGCCGAAAGATGGTTATCGGTTCAAGGGCGC 
AAAGTGAGTGAACCTTTCGGGGCGATGATAAGGGGTAGAGAGAATGCCTCGAGCCAACGCCCGAGTAGCAGG 
CGCTACGGCGCTGAAGTAACTCATGCCACACTCCCAAGAAAAGCCCGAACGACCTTCAACGAGTGGGTACCT 
GTACCTGAAACCGACACAGGTAGGTAGGTAGAGAATACCTAGGGGCGCGAGACAACTCTCTCTAAGGAACTC 
GGCAAAATAGCCCCGCAACTTCGGGAGAAGGGGCGCCTTCTCGCAGAGGAGGTCGCAGTGACCAGGCCCAGG 
CGACTGTTTACCAAAAACACAGGTCTCCGCAAAGTCGTAAGACCATGTATGGGGGCTGACGCCTGCCCAGTG 
CCGGGAGGTGAAGGAAGTTGGTGACCTGATGACAGGAAAGCTAGCGACCGAAGCCCCGGTGAACGGCGGCCG 
TAACTATAACGGTCCTAAGGTAGCGAAATTCCTTGTCGGGTAAGTTCCGACCCGCACGAAAGGCGTAACGAT 
CTGGGCACTGTCTCGGAGAGAGACTCGGTGAAATAGACATGTCTGTGAAGATGCGGACTACCCGCACCCGGA 
CAGAAAGACCCTATGAAGCTTTACTGTTCCCTGAGATTGGCTTTGGGCTCTTCCTGCGCAGCTTAGGTGGAA 
GGCGAGGAAGGTCCTCTTTCGGGGGGGCTCGAGCCATCAGTGAAATACCACTCTAGGAGAGCCAAAATTCTC 
ACTTTGCGGCGTCACTCACGGGCCAAGGGACAGTCTCAGGTAGACAGTTTCTATGGGGCGTAGGCCTCCCAA 
AGGGTAACGGAGGCGCGCAAAGGTTCCCTCGGGCTGGACGGAAATCAGCCTTCAAGTGCAAAGGCGGAAGGG 
AGCTCGACTGCAAGACCCACCCGTCGAGCAGGGACGAAAGTCGGCCTTAGTGATCCGACGGTGCCGGGTGGA 
AGGGCCGTCGCTCAACGGATAAAAGTTACTCTAGGGATAACAGGCTGATCTTCCCCAAGAGTTCACATCGAC 
GGGAAGGTTTGGCACCTCGATGTCGGCTCTTCGCCACCTGGGGCGGTAGTACGTTCCAAGGGTTGGGCTGTT 
CGCCCATCAAAGCGGTACGTGAGCTGGGTTCAGAACGTCGTGAGACAGTTCGGTCCATATCCGGTGCGGGCG 
TTGGAGCATTGATAGGACCTTCCCCTAGTACGAGAGGACCGGGAAGGACGCACCTCCGGTGTACCAGTTATC 
GTGCCCGCGGTACACGCTGGGTAGCCAAGTGCGGAGCGGATAACTGCTGAAAGCATCTAAGCAGGAAGCCCA 
CCCAAAGATGAGTGCTCCCCT

>Pseudoselaginella_ternifolia
TCCAAACGGGGAAGGGCTTGCGGTGGATACCTAGGCACCCAGGGACGAAGAAGGGCGTAGCAAGCGACAATG 
CTTCGGGAAGCCAGAGATAAGCATAGATCCGGAGATCCCCGAATGGGTTAACCCCTTGAAGAACTGCCGAAT 
CCGTGGGATGGGGCAAGAGACAACCTGGCAAACCGAAACATCCAAATAGCCGGGGGAAGAGAAAGCAAAAGC 
GATTCCCGTAGTAGCGGCGAGCGAAGAGGGAGTAGCCTAAACCGTGGGAACGGGGTTGTGGGAGAGCAATAA 
GTATAAGGTTGTGCTGCTAGGTGAAGCGGTCGAGTCCCGCATCCCAGACGGTTAGAGTCCGGTAGCCGGAAG 
CAGCACAGGCTGACGCTCCGACCCGAGTAGCATGGGGCACGTGGAATCCCGTGCGAATCAGCGAGGACCACC 
TCGTAAGGCTAAATACTTCTGGGTGACCGATAGCGAAATAGTACCGTGAGGGAAAGGTGAAAAGAACCCCCA 
CCAGGGAGTGAAATAGAACATGAAACCGTAAGCTCCCGAGCAGTGGGAGGATAATTGGATATCTGACCGCGT 
GCCTGTTGAAGAATGAGCCGGCGACTTATAGGCGGCGGCCTGGTTAAGGAAACCCACCGGAGCCGTAGCGAA 
AGCGAGTCTTCCCAGGGGCAACTGTCGCTGCTTATGGACCCGAACCCGGGTGATCTATCCATGACCAGGATG 
AAGCTTGGATGAAACTAGGTGGAGGTCCGAACCGACTGATGTTGAAAAATCAGCGGATGAGTCGTGGTTAGG 
GGTGAAATGCCACTCGAACCCGGAGCTAGCGGGCTGCGACTGGTTCTCCCCGCAGCATTTTGAGGCGCAGCA
TTTGACTAGGCTACCTGGGGGTAAAGCACTGTTACGGTGGAGGCAAACTCTGCCGATGCAAACTCTGAATAC
TAGGTATGACCCCCGAGTAACACGGATTATGAGGGTCAGCCAGTGAGACTATGGGGGATAAGCTTCACCGTC
GAGAGGGAAATAGCCCTGATCACCAGCTAAGGCCCCTAAATGACCGCTCAGTGGTAAAGGAGGTAGGAGTGC
AAAGACAGCCGGGAGGTTTGCCCAGAAGCAGCCACCCTTGAAAGAGTGCGTAATAGCTCACTGATCAAGCGC
TCCTGCGCCGAGGATGAACGGGACTAAGCGGTCTGCCGAAGCTGTGGGATGTCGAAAAACACATCGGTAGGG 
GAGCGTTCCGCCGCCTCGGAAGGAGGAAGCACCAGCGCGAGCAGGTGCGGACGAAGCGGAAGCGAGAATGTC 
GGCTTGAGTAACGCAAACATTGGTGAGAATCCAATGCCCCGAAAACCCAAGGGTTCCTCCGCAAGGTTCGTC 
CACGGAGGGTGAGTCAGGGCCTAAGATCAGGCCGATAGGCGTAGTCGATGGACAACAGGCGAATATTCCTGT 
ACTACCCATCGTTGGTCACGGGGGACGGAGGAGGCCAGGTTAGCCGAAAGATGGTTATCGGTTCAAGGGCGC 
AAAGTGAGTGAACCTTTCGGGGCGATGATAAGGGGTAGAGAGAATGCCTCGAGCCAACGCCCGAGTAGCAGG 
CGCTACGGCGCTGAAGTAACTCATGCCACACTCCCAAGAAAAGCCCGAACGACCTTCAACGAGTGGGTACCT 
GTACCTGAAACCGACACAGGTAGGTAGGTAGAGAATACCTAGGGGCGCGAGACAACTCTCTCTAAGGAACTC 
GGCAAAATAGCCCCGCAACTTCGGGAGAAGGGGCGCCTTCTCGCAGAGGAGGTCGCAGTGACCAGGCCCAGG 
CGACTGTTTACCAAAAACACAGGTCTCCGCAAAGTCGTAAGACCATGTATGGGGGCTGACGCCTGCCCAGTG 
CCGGGAGGTGAAGGAAGTTGGTGACCTGATGACAGGAAAGCTAGCGACCGAAGCCCCGGTGAACGGCGGCCG 
TAACTATAACGGTCCTAAGGTAGCGAAATTCCTTGTCGGGTAAGTTCCGACCCGCACGAAAGGCGTAACGAT 
CTGGGCACTGTCTCGGAGAGAGACTCGGTGAAATAGACATGTCTGTGAAGATGCGGACTACCCGCACCCGGA 
CAGAAAGACCCTATGAAGCTTTACTGTTCCCTGAGATTGGCTTTGGGCTCTTCCTGCGCAGCTTAGGTGGAA 
GGCGAGGAAGGTCCTCTTTCGGGGGGGCTCGAGCCATCAGTGAAATACCACTCTAGGAGAGCCAAAATTCTC 
ACTTTGCGGCGTCACTCACGGGCCAAGGGACAGTCTCAGGTAGACAGTTTCTATGGGGCGTAGGCCTCCCAA 
AGGGTAACGGAGGCGCGCAAAGGTTCCCTCGGGCTGGACGGAAATCAGCCTTCAAGTGCAAAGGCGGAAGGG 
AGCTCGACTGCAAGACCCACCCGTCGAGCAGGGACGAAAGTCGGCCTTAGTGATCCGACGGTGCCGGGTGGA 
AGGGCCGTCGCTCAACGGATAAAAGTTACTCTAGGGATAACAGGCTGATCTTCCCCAAGAGTTCACATCGAC 
GGGAAGGTTTGGCACCTCGATGTCGGCTCTTCGCCACCTGGGGCGGTAGTACGTTCCAAGGGTTGGGCTGTT 
CGCCCATCAAAGCGGTACGTGAGCTGGGTTCAGAACGTCGTGAGACAGTTCGGTCCATATCCGGTGCGGGCG 
TTGGAGCATTGATAGGACCTTCCCCTAGTACGAGAGGACCGGGAAGGACGCACCTCCGGTGTACCAGTTATC 
GTGCCCGCGGTACACGCTGGGTAGCCAAGTGCGGAGCGGATAACTGCTGAAAGCATCTAAGCAGGAAGCCCA 
CCCAAAGATGAGTGCTCCCCT

>Pseudoselaginella_tetramera
TCCAAACGGGGAAGGGCTTGCGGTGGATACCTAGGCACCCAGGGACGAAGAAGGGCGTAGCAAGCGACAATG 
CTTCGGGAAGCCAGAGATAAGCATAGATCCGGAGATCCCCGAATGGGTTAACCCCTTGAAGAACTGCCGAAT 
CCGTGGGATGGGGCAAGAGACAACCTGGCAAACCGAAACATCCAAATAGCCGGGGGAAGAGAAAGCAAAAGC 
GATTCCCGTAGTAGCGGCGAGCGAAGAGGGAGTAGCCTAAACCGTGGGAACGGGGTTGTGGGAGAGCAATAA 
GTATAAGGTTGTGCTGCTAGGTGAAGCGGTCGAGTCCCGCATCCCAGACGGTTAGAGTCCGGTAGCCGGAAG 
CAGCACAGGCTGACGCTCCGACCCGAGTAGCATGGGGCACGTGGAATCCCGTGCGAATCAGCGAGGACCACC 
TCGTAAGGCTAAATACTTCTGGGTGACCGATAGCGAAATAGTACCGTGAGGGAAAGGTGAAAAGAACCCCCA 
CCAGGGAGTGAAATAGAACATGAAACCGTAAGCTCCCGAGCAGTGGGAGGATAATTGGATATCTGACCGCGT 
GCCTGTTGAAGAATGAGCCGGCGACTTATAGGCGGCGGCCTGGTTAAGGAAACCCACCGGAGCCGTAGCGAA 
AGCGAGTCTTCCCAGGGGCAACTGTCGCTGCTTATGGACCCGAACCCGGGTGATCTATCCATGACCAGGATG 
AAGCTTGGATGAAACTAGGTGGAGGTCCGAACCGACTGATGTTGAAAAATCAGCGGATGAGTCGTGGTTAGG 
GGTGAAATGCCACTCGAACCCGGAGCTAGCTGGTTCTCCCCGAAATGCGTTGAGGCGCAGCGGTTGACTAGG
CTACCTGGAAGTATACCTGGAAGACGGTGCGGGCTGCCTGGAGAGCGGTACCAAACCGGGGCAACCGGGGCA
ACTCTGAATACTAGGTATGACCTTCGTATGACCTTGAGTAACACGGTCAGCTAGTGAGACGATGTTCACCGT
CGAGAGGGAAACAGCCCGGATCACCAGCTAAGGCCCTAAATGACCGCTCAGTGGTACAAGGAGGTAGGAGTG
AAAGACAGCCGGGAGGTTTGCCCAGAAGCAGCCACCCTTGAAAGAGTGCGTAATAGCTCACTGATCAAGCGC
TCCTGCGCCGAGGATGAACGGGACTAAGCGGTCTGCCGAAGCTGTGGGATGTCGAAAAACACATCGGTAGGG
GAGCGTTCCGCCGCCTCGGAAGGAGGAAGCACCAGCGCGAGCAGGTGCGGACGAAGCGGAAGCGAGAATGTC
GGCTTGAGTAACGCAAACATTGGTGAGAATCCAATGCCCCGAAAACCCAAGGGTTCCTCCGCAAGGTTCGTC
CACGGAGGGTGAGTCAGGGCCTAAGATCAGGCCGATAGGCGTAGTCGATGGACAACAGGCGAATATTCCTGT 
ACTACCCATCGTTGGTCACGGGGGACGGAGGAGGCCAGGTTAGCCGAAAGATGGTTATCGGTTCAAGGGCGC 
AAAGTGAGTGAACCTTTCGGGGCGATGATAAGGGGTAGAGAGAATGCCTCGAGCCAACGCCCGAGTAGCAGG 
CGCTACGGCGCTGAAGTAACTCATGCCACACTCCCAAGAAAAGCCCGAACGACCTTCAACGAGTGGGTACCT 
GTACCTGAAACCGACACAGGTAGGTAGGTAGAGAATACCTAGGGGCGCGAGACAACTCTCTCTAAGGAACTC 
GGCAAAATAGCCCCGCAACTTCGGGAGAAGGGGCGCCTTCTCGCAGAGGAGGTCGCAGTGACCAGGCCCAGG 
CGACTGTTTACCAAAAACACAGGTCTCCGCAAAGTCGTAAGACCATGTATGGGGGCTGACGCCTGCCCAGTG 
CCGGGAGGTGAAGGAAGTTGGTGACCTGATGACAGGAAAGCTAGCGACCGAAGCCCCGGTGAACGGCGGCCG 
TAACTATAACGGTCCTAAGGTAGCGAAATTCCTTGTCGGGTAAGTTCCGACCCGCACGAAAGGCGTAACGAT 
CTGGGCACTGTCTCGGAGAGAGACTCGGTGAAATAGACATGTCTGTGAAGATGCGGACTACCCGCACCCGGA 
CAGAAAGACCCTATGAAGCTTTACTGTTCCCTGAGATTGGCTTTGGGCTCTTCCTGCGCAGCTTAGGTGGAA 
GGCGAGGAAGGTCCTCTTTCGGGGGGGCTCGAGCCATCAGTGAAATACCACTCTAGGAGAGCCAAAATTCTC 
ACTTTGCGGCGTCACTCACGGGCCAAGGGACAGTCTCAGGTAGACAGTTTCTATGGGGCGTAGGCCTCCCAA 
AGGGTAACGGAGGCGCGCAAAGGTTCCCTCGGGCTGGACGGAAATCAGCCTTCAAGTGCAAAGGCGGAAGGG 
AGCTCGACTGCAAGACCCACCCGTCGAGCAGGGACGAAAGTCGGCCTTAGTGATCCGACGGTGCCGGGTGGA 
AGGGCCGTCGCTCAACGGATAAAAGTTACTCTAGGGATAACAGGCTGATCTTCCCCAAGAGTTCACATCGAC 
GGGAAGGTTTGGCACCTCGATGTCGGCTCTTCGCCACCTGGGGCGGTAGTACGTTCCAAGGGTTGGGCTGTT 
CGCCCATCAAAGCGGTACGTGAGCTGGGTTCAGAACGTCGTGAGACAGTTCGGTCCATATCCGGTGCGGGCG 
TTGGAGCATTGATAGGACCTTCCCCTAGTACGAGAGGACCGGGAAGGACGCACCTCCGGTGTACCAGTTATC 
GTGCCCGCGGTACACGCTGGGTAGCCAAGTGCGGAGCGGATAACTGCTGAAAGCATCTAAGCAGGAAGCCCA 
CCCAAAGATGAGTGCTCCCCT');
	
	%primers = ();
	@{$primers{0}} = ('CTCTGAATACTAGGTATGACCCCCG','GGCTGACCCTTAGCAACCGTGTTAC','AATGCGAGAGGCTGCGAGAGCGTTA','ACGGTGAAGTGAAGTGAAGCTTATC','ACTGTTACGGACTGTTACGGTGCGG','TTTCGCTGTTTCCCTGTTTCCTCG');
	@{$primers{1}} = ('CTCTGAATACTAGGTATGACCCCCG','TAGCAACCGTGTTAC','GGCTACCTGAGGTTACCTGAGGTTA','TACTGGCTGTTTCCC','TGAGGCGCAGCGATT','GGCCTTAGCTGGTGA');
	@{$primers{2}} = ('CACGGATTATGAGGG','TAGTCTCACTGGCTG','GCAAACTCTGCCGATGCAAACTCTG','TCAGGGCTATTTCCC','CGCAGCATTTTGAGGCGCAGCATTT','GGCCTTAGCTGGTGA');
	@{$primers{3}} = ('TAGGTATGACCTTCGTATGACCTTG','TCGTCTCACTAGCTG','GGCTACCTGGAAGTATACCTGGAAG','CCACTGAGCGGTCAT');
	$prCount = 3;
	$displayPrCount = 4;
	
	$IF -> delete('0.0','end');
	$IR -> delete('0.0','end');
	$MF -> delete('0.0','end');
	$MR -> delete('0.0','end');
	$OF -> delete('0.0','end');
	$OR -> delete('0.0','end');
	$FIPentry1 -> delete('0.0','end');
	$RIPentry1 -> delete('0.0','end');
	$F3entry1 -> delete('0.0','end');
	$R3entry1 -> delete('0.0','end');

	$IF -> insert('end',$primers{0}[0]); 
	$IR -> insert('end',$primers{0}[1]);
	$MF -> insert('end',$primers{0}[2]);
	$MR -> insert('end',$primers{0}[3]);
	$OF -> insert('end',$primers{0}[4]);
	$OR -> insert('end',$primers{0}[5]);
	$FIPentry1 -> insert('end', rc($primers{0}[0]) . '-TTTTT-' . $primers{0}[2]);
	$RIPentry1 -> insert('end', rc($primers{0}[1]) . '-TTTTT-' . $primers{0}[3]);
	$F3entry1 -> insert('end', $primers{0}[4]);
	$R3entry1 -> insert('end', $primers{0}[5]);
	return(0);
	}

sub saveFile { ### user will select file to open
	my $sfile = $mw -> getSaveFile (-initialfile=>'eLAMP-results.csv',-defaultextension=>'csv');
	if(length($sfile)){
		open(FILE, ">$sfile") or die $!;
		my $buffer = join("\n", @results);
		print FILE $buffer;
		close(FILE);
		}
	return(0);
	}

sub sequenceData {
	my $file = $_[0];
	my $sample = ();
	my $sequence = ();
	open(INFILE, '<', $file) or die("Cannot open $file!\n");
	while(my $line = <INFILE>){
		chomp($line);
		if(length($line)){
			if($line =~ m/^>/){ ### is name
				$line =~ tr/,/;/;
				if(length($sequence)){
					$sample .= $sequence . "\n";
					}
				$sample .= $line . "\n";
				$sequence = ();
				} else { ### is sequence
						$line = uc($line);
						$line =~ tr/ACGTNVDBHWMRKSY//cd;
						$sequence .= $line;
						}
			}
		}
	$sample .= $sequence;
	close(INFILE);
	if(length($sample) && ($sample =~ m/^>/)){
		$template -> Subwidget('text') -> delete('0.0','end');
		$template -> Subwidget('text') -> insert('end', $sample);
		return(0);
		} else {
			return(1);
			}
	}
			
sub showAmpl{
	$pane -> Subwidget('scrolled') -> configure(-state=>'normal');
	$pane -> Subwidget('scrolled') -> delete('0.0','end');
	if($seqDisplay eq 'amplified target'){
		$pane -> Subwidget('scrolled') -> insert('end', $amplSeqs);
		}elsif($seqDisplay eq 'failed to amplify'){
			$pane -> Subwidget('scrolled') -> insert('end', $deadSeqs);
			}
	$pane2 -> Subwidget('scrolled') -> configure(-state=>'normal');
	$pane2 -> Subwidget('scrolled') -> delete('0.0','end');
	if($seqDisplay2 eq 'amplified target'){
		$pane2 -> Subwidget('scrolled') -> insert('end', $amplSeqs);
		}elsif($seqDisplay2 eq 'failed to amplify'){
			$pane2 -> Subwidget('scrolled') -> insert('end', $deadSeqs);
			}
	$pane -> Subwidget('scrolled') -> configure(-state=>'disable');
	$pane2 -> Subwidget('scrolled') -> configure(-state=>'disable');
	return(0);
	}
				
sub showSeqs{
	$amplSeqs = ();
	$deadSeqs = ();
	my $tic = ();
	for(my $w = 1; $w <= $#{$semiOutput->[0]}; $w++){
		if((length($oPrimers{$currResult}[4])) && (length($oPrimers{$currResult}[5]))){
			if($semiOutput->[0][$w] eq "$oPrimers{$currResult}[0]+$oPrimers{$currResult}[1]|$oPrimers{$currResult}[2]+$oPrimers{$currResult}[3]|$oPrimers{$currResult}[4]+$oPrimers{$currResult}[5]"){
				for(my $s = $#{$semiOutput}; $s >= 1; $s--){
					if($semiOutput->[$s][$w] eq '1'){
						$amplSeqs .= $semiOutput->[$s][0] . "\n";
						}elsif($semiOutput->[$s][$w] eq '0'){
							$deadSeqs .= $semiOutput->[$s][0] . "\n";
						}
					}
				}
			}else{
				if($semiOutput->[0][$w] eq "$oPrimers{$currResult}[0]+$oPrimers{$currResult}[1]|$oPrimers{$currResult}[2]+$oPrimers{$currResult}[3]"){
					for(my $s = $#{$semiOutput}; $s >= 1; $s--){
						if($semiOutput->[$s][$w] eq '1'){
							$amplSeqs .= $semiOutput->[$s][0] . "\n";
							}elsif($semiOutput->[$s][$w] eq '0'){
								$deadSeqs .= $semiOutput->[$s][0] . "\n";
								}
						}
					}
				}
		}
	&showAmpl;
	return(0);
	}
	
sub testConditions{
	$I = int($ienm -> get());
	$M = int($menm -> get());
	$O = int($oenm -> get());
	$i = int($ianm -> get());
	$m = int($manm -> get());
	$o = int($oanm -> get());
	$A = int($bigAmplicon ->get());
	$a = int($shortAmplicon ->get());
	$s = int($innerSpace ->get());
	$l = int($inner2middle ->get());

	if(($I <= 0) || ($I > 3) || ($M > 3) || ($M <= 0) || ($O > 3) || ($O <= 0)){
		my $error = $mw->Dialog(-title => 'A simple mistake',
		-text => 'The number of nucleotides for exact matching does not comply eLAMP standards! (integer number between 1 and 3)') -> Show();
		$mistakes = 6;
		}
	if(($i > 100) || ($i <= 0) || ($m > 100) || ($m <= 0) || ($o > 100) || ($o <= 0)){
		my $error = $mw->Dialog(-title => 'A simple mistake',
		-text => 'At least one of the approximate matching values is not a valid percentage! (0 > x <= 100)') -> Show();
		$mistakes = 6;
		}
	if(($A <= ($a + (2 * $l) + 30)) || ($a <= ($s + 30))){
		my $error = $mw->Dialog(-title => 'A simple mistake',
		-text => 'At least one of the primer spacing values is not valid') -> Show();
		$mistakes = 6;
		}

	return(0);
	}
		
sub testTab{
	my $last = $tabRecord;
	$tabRecord = $tabs -> raised();
	if($last eq 'page2'){ 
		&changeSet(4);
		if($mistakes == 4){
			my $tab2 = $tabs->raise('page2');
			$mistakes = -1;
			return(0);
			}
		} elsif($last eq 'page3'){
			&changeSet(5);
			if($mistakes == 5){
				my $tab3 = $tabs->raise('page3');
				$mistakes = -1;
				return(0);
				}
			} elsif($last eq 'page4'){
				&testConditions;
				if($mistakes == 6){
					my $tab4 = $tabs->raise('page4');
					$mistakes = -1;
					return(0);
					}
				}
	return(0);
	}
		
sub weirdPrimer {
	my $weirdo = $_[0];
	my $fprimer = $_[1];
	my $direction = $_[2];
	my $fset = ();
	if(($direction == 2) || ($direction == 3) || ($direction == 5)){
		if($fprimer == 0){
			$fset = 'FIP';
			}elsif($fprimer == 1){
				$fset = 'RIP(BIP)';
				}elsif($fprimer == 2){
					$fset = 'FIP';
					}elsif($fprimer == 3){
						$fset = 'RIP(BIP)';
						}elsif($fprimer == 4){
							$fset = 'F3';
							}elsif($fprimer == 5){
								$fset = 'R3(B3)';
								}
		}elsif(($direction == 0) || ($direction == 1) || ($direction == 4)){
			if($fprimer == 0){
				$fset = 'inner forward';
				}elsif($fprimer == 1){
					$fset = 'inner reverse';
					}elsif($fprimer == 2){
						$fset = 'middle forward';
						}elsif($fprimer == 3){
							$fset = 'middle reverse';
							}elsif($fprimer == 4){
								$fset = 'outer forward';
								}elsif($fprimer == 5){
									$fset = 'outer reverse';
									}
			
			}
	if(length($weirdo)){
		my $error = $mw->Dialog(-title => 'A simple mistake', -text => "$weirdo is an illegal $fset primer") -> Show();
		} else {
			my $error = $mw->Dialog(-title => 'A simple mistake', -text => "blank $fset primer") -> Show();
			}
	$mistakes = $direction;
	return(0);
	}	

MainLoop;

