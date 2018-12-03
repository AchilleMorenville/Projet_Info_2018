
PassedTests = {Cell.new 0}
TotalTests  = {Cell.new 0}

% Time in seconds corresponding to 5 samples.
FiveSamples = 0.00011337868

% Takes a list of samples, round them to 4 decimal places and multiply them by
% 10000. Use this to compare list of samples to avoid floating-point rounding
% errors.
fun {Normalize Samples}
   {Map Samples fun {$ S} {IntToFloat {FloatToInt S*10000.0}} end}
end

proc {Assert Cond Msg}
   TotalTests := @TotalTests + 1
   if {Not Cond} then
 {System.show Msg}
   else
 PassedTests := @PassedTests + 1
   end
end

proc {AssertEquals A E Msg}
   TotalTests := @TotalTests + 1
   if A \= E then
 {System.show Msg}
 {System.show actual(A)}
 {System.show expect(E)}
   else
 PassedTests := @PassedTests + 1
   end
end

% Prevent warnings if these are not used.
{ForAll [FiveSamples Normalize Assert AssertEquals] Wait}




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST PartitionToTimedNotes

proc {TestNotes P2T}
   P=[a b4 c#4]
in
   {Browse {P2T P}}
end

proc {TestChords P2T}
   P=[[a b4 c#4] d]
in
   {Browse {P2T P}} 
end

proc {TestIdentity P2T}
% test that extended notes and chord go from input to output unchanged
   P=[note(name:a octave:2 sharp:true duration:4 instrument:piano) [note(name:c octave:4 sharp:true duration:4 instrument:piano) note(name:c octave:4 sharp:true duration:4 instrument:piano)]]
in
   {Browse {P2T P}}
end

proc {TestDuration P2T}
   P=[duration(seconds:3.0 [a b#2 [a a]])]
in
   {Browse {P2T P}}
end

proc {TestStretch P2T}
   P=[stretch(factor:2.0 [a b [a a]])]
in
   {Browse {P2T P}}
end

proc {TestDrone P2T}
   P=[drone(note:a amount:3)]
in
   {Browse {P2T P}}
end

proc {TestTranspose P2T}
   P=[transpose(semitones:5 [a4 a3 a5 c6]) transpose(semitones: ~5 [a4 a3 a5 c6])]
in
   {Browse {P2T P}}
end

proc {TestP2TChaining P2T}
% test a partition with multiple transformations
   P=[duration(seconds:3.0 [a b#2 [a a]]) stretch(factor:2.0 [a b [a a]]) drone(note:a amount:3) transpose(semitones:5 [a4 a3 a5 c6]) transpose(semitones: ~5 [a4 a3 a5 c6])]
in
   {Browse {P2T P}}
end

proc {TestEmptyChords P2T}
   {Browse {P2T [nil}}
end

proc {TestP2T P2T}
   {Browse 'notes'}
   {TestNotes P2T}
   {Browse 'chords'}
   {TestChords P2T}
   {Browse 'extendedNoteschord'}
   {TestIdentity P2T}
   {Browse 'duration'}
   {TestDuration P2T}
   {Browse 'stretch'}
   {TestStretch P2T}
   {Browse 'drone'}
   {TestDrone P2T}
   {Browse 'transpose'}
   {TestTranspose P2T}
   {Browse 'mixdetout'}
   {TestP2TChaining P2T}
   {Browse 'emptychord'}
   {TestEmptyChords P2T}   
   {AssertEquals {P2T nil} nil 'nil partition'}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST Mix

proc {TestSamples P2T Mix}
   {Browse {Mix P2T [samples([0.2 0.6 0.4 1 ~0.5 ~0.7 1])]}}
end

Tune = [b b c5 d5 d5 c5 b a g g a b]
End1 = [stretch(factor:1.5 [b]) stretch(factor:0.5 [a]) stretch(factor:2.0 [a])]
End2 = [stretch(factor:1.5 [a]) stretch(factor:0.5 [g]) stretch(factor:2.0 [g])]
Interlude = [a a b g a stretch(factor:0.5 [b c5])
	b g a stretch(factor:0.5 [b c5])
	b a g a stretch(factor:2.0 [d]) ]

% This is not a music.
Partition = {Flatten [Tune End1 Tune End2 Interlude Tune End2]}

proc {TestPartition P2T Mix}
% This is a music :)
   {Browse {Mix P2T [partition(Partition)]}}
end

proc {TestWave P2T Mix}
   {Browse {Mix P2T [wave('C:/Users/Olivier/Documents/Projet_Info_2018/chicken.wav')]}}
end

proc {TestMerge P2T Mix}
   skip
end

proc {TestReverse P2T Mix}
   {Browse {Mix P2T [reverse([partition([a b c])])]}}
end

proc {TestRepeat P2T Mix}
   {Browse {Mix P2T [repeat(amount:2 [partition([a b c])])]}}
end

proc {TestLoop P2T Mix}
   {Browse {Mix P2T [loop(duration:4.0 [partition([a b c])])]}}
end

proc {TestClip P2T Mix}
   skip
end

proc {TestEcho P2T Mix}
   skip
end

proc {TestFade P2T Mix}
   skip
end

proc {TestCut P2T Mix}
   {Browse {Mix P2T [cut(start:0.5 finish:2.5 [partition([a b c])])]}}
end

proc {TestMix P2T Mix}
   {TestSamples P2T Mix}
   {TestPartition P2T Mix}
   {TestWave P2T Mix}
   {TestMerge P2T Mix}
   {TestReverse P2T Mix}
   {TestRepeat P2T Mix}
   {TestLoop P2T Mix}
   {TestClip P2T Mix}
   {TestEcho P2T Mix}
   {TestFade P2T Mix}
   {TestCut P2T Mix}
   {AssertEquals {Mix P2T nil} nil 'nil music'}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc {Test Mix P2T}
   {Property.put print print(width:100)}
   {Property.put print print(depth:100)}
   {System.show 'tests have started'}
   {TestP2T P2T}
   {System.show 'P2T tests have run'}
   {TestMix P2T Mix}
   {System.show 'Mix tests have run'}
   {System.show test(passed:@PassedTests total:@TotalTests)}
end

fun{BackToTheFutur}
   Ronde=4.0
   Blanche=Ronde/2.0
   Noir=Blanche/2.0
   Croche=Noir/2.0
   DoubleCroche=Croche/2.0
   Soupir=Noir
   DemiSoupir=Croche

   P=[silence(duration:Soupir)
   note(name:g octave:4 sharp:false duration:Noir instrument:piano)
   note(name:d octave:5 sharp:false duration:Noir instrument:piano)
   note(name:g octave:5 sharp:false duration:Croche instrument:piano)
   note(name:f octave:5 sharp:true duration:Noir instrument:piano)
   note(name:f octave:5 sharp:false duration:Croche instrument:piano)
   note(name:e octave:5 sharp:false duration:Noir instrument:piano)
   note(name:c octave:5 sharp:false duration:DoubleCroche instrument:piano)
   note(name:b octave:5 sharp:false duration:DoubleCroche instrument:piano)
   note(name:c octave:4 sharp:false duration:Ronde instrument:piano)
   silence(duration:Soupir)
   note(name:g octave:4 sharp:false duration:Noir instrument:piano)
   note(name:c octave:5 sharp:false duration:Noir instrument:piano)
   note(name:b octave:5 sharp:false duration:Croche instrument:piano)
   note(name:f octave:5 sharp:true duration:Noir instrument:piano)
   note(name:f octave:5 sharp:false duration:Croche instrument:piano)
   note(name:e octave:5 sharp:false duration:Noir instrument:piano)
   note(name:d octave:5 sharp:false duration:DoubleCroche instrument:piano)
   note(name:c octave:5 sharp:false duration:DoubleCroche instrument:piano)
   note(name:d octave:5 sharp:false duration:Ronde instrument:piano)
   note(name:d octave:5 sharp:false duration:Ronde instrument:piano)
   note(name:d octave:4 sharp:false duration:Blanche instrument:piano)
   note(name:g octave:4 sharp:false duration:Blanche instrument:piano)
   note(name:c octave:4 sharp:true duration:Blanche instrument:piano)
   note(name:d octave:5 sharp:false duration:DoubleCroche instrument:piano)
   note(name:e octave:5 sharp:false duration:DoubleCroche instrument:piano)
   note(name:d octave:5 sharp:false duration:Noir instrument:piano)
   note(name:g octave:4 sharp:false duration:DoubleCroche instrument:piano)
   note(name:a octave:4 sharp:false duration:DoubleCroche instrument:piano)
   ]
in
   [partition(P)]
end
