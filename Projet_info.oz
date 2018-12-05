local
	% See project statement for API details.
	[Project] = {Link ['C:/Users/olivi/Documents/GitHub/Projet_Info_2018/Project2018.ozf']}
	Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% Translate a note to the extended notation.
	fun {NoteToExtended Note}
		case Note
		of Name#Octave then
			note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
		[] Atom then
			if Atom == silence then
				silence(duration:1.0)
			else 
				case {AtomToString Atom}
				of [_] then
					note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
				[] [N O] then
					note(name:{StringToAtom [N]}
						octave:{StringToInt [O]}
						sharp:false
						duration:1.0
						instrument: none)
				end
			end
		end
	end

	% Translate a chord to an extended chord
	fun {ChordToExtended Chord}
		case Chord
		of nil then nil
		[] H|T then {NoteToExtended H}|{ChordToExtended T} 
		end
	end
	%Retourn si N est au format d'une extended note
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%retourn la note transposé de N demi-ton
	fun{TransposeNote ST N}
		if ST == 0 then N
		else
			case N
			of note(name:N octave:O sharp:S duration:D instrument:I) then
				if ST < 0 then
					if N == b andthen S == false then {TransposeNote ST+1 note(name:a octave:O sharp:true duration:D instrument:I)}
					elseif N == a andthen S == true then {TransposeNote ST+1 note(name:a octave:O sharp:false duration:D instrument:I)}
					elseif N == a andthen S == false then {TransposeNote ST+1 note(name:g octave:O sharp:true duration:D instrument:I)}
					elseif N == g andthen S == true then {TransposeNote ST+1 note(name:g octave:O sharp:false duration:D instrument:I)}
					elseif N == g andthen S == false then {TransposeNote ST+1 note(name:f octave:O sharp:true duration:D instrument:I)}
					elseif N == f andthen S == true then {TransposeNote ST+1 note(name:f octave:O sharp:false duration:D instrument:I)}
					elseif N == f andthen S == false then {TransposeNote ST+1 note(name:e octave:O sharp:false duration:D instrument:I)}
					elseif N == e andthen S == false then {TransposeNote ST+1 note(name:d octave:O sharp:true duration:D instrument:I)}
					elseif N == d andthen S == true then {TransposeNote ST+1 note(name:d octave:O sharp:false duration:D instrument:I)}
					elseif N == d andthen S == false then {TransposeNote ST+1 note(name:c octave:O sharp:true duration:D instrument:I)}
					elseif N == c andthen S == true then {TransposeNote ST+1 note(name:c octave:O sharp:false duration:D instrument:I)}
					elseif N == c andthen S == false then {TransposeNote ST+1 note(name:b octave:(O-1) sharp:false duration:D instrument:I)}
					else error(cause:N comment:noteARealNote)
					end
				else
					if N == c andthen S == false then {TransposeNote ST-1 note(name:c octave:O sharp:true duration:D instrument:I)}
					elseif N == c andthen S == true then {TransposeNote ST-1 note(name:d octave:O sharp:false duration:D instrument:I)}
					elseif N == d andthen S == false then {TransposeNote ST-1 note(name:d octave:O sharp:true duration:D instrument:I)}
					elseif N == d andthen S == true then {TransposeNote ST-1 note(name:e octave:O sharp:false duration:D instrument:I)}
					elseif N == e andthen S == false then {TransposeNote ST-1 note(name:f octave:O sharp:false duration:D instrument:I)}
					elseif N == f andthen S == false then {TransposeNote ST-1 note(name:f octave:O sharp:true duration:D instrument:I)}
					elseif N == f andthen S == true then {TransposeNote ST-1 note(name:g octave:O sharp:false duration:D instrument:I)}
					elseif N == g andthen S == false then {TransposeNote ST-1 note(name:g octave:O sharp:true duration:D instrument:I)}
					elseif N == g andthen S == true then {TransposeNote ST-1 note(name:a octave:O sharp:false duration:D instrument:I)}
					elseif N == a andthen S == false then {TransposeNote ST-1 note(name:a octave:O sharp:true duration:D instrument:I)}
					elseif N == a andthen S == true then {TransposeNote ST-1 note(name:b octave:O sharp:false duration:D instrument:I)}
					elseif N == b andthen S == false then {TransposeNote ST-1 note(name:c octave:(O+1) sharp:false duration:D instrument:I)}
					else error(cause:N comment:notRealNote)
					end
				end
			else error(cause:N comment:notNote)
			end
		end
	end

	fun {PartitionToTimedList Partition} 

		fun{IsExtendedNote EN}
			case EN of silence(duration:D) then true
			[] note(name:N octave:O sharp:S duration:D instrument:I) then true
			else false
			end
		end

		%Retourn si N est au format d un extended chord
		fun{IsExtendedChord EC}
			case EC of nil then true
			[]H|T then if {IsExtendedNote H}==false then false else {IsExtendedChord T} end
			else false
			end
		end

		%Excecute une transformation
		fun{TransformationConvert Tr}
			%Modifie la duree des elements de la FlatPartition par Duration
			fun{DurationTransformation Duration FlatPartition}
				fun{GetDurationParition P Acc}
					case P of nil then Acc
					[] H|T then 
						if {IsExtendedNote H} then
							{GetDurationParition T Acc+H.duration}  
						elseif {IsExtendedChord H} then
							{GetDurationParition T Acc+H.1.duration}
						end
					end
				end
			in
				local Factor in
					Factor=Duration/{GetDurationParition FlatPartition 0.0}
					{StretchTransformation Factor FlatPartition}
				end 
			end

			fun{DroneTransformation Element NBR}
				case Element of H|T then
					if NBR==0 then nil
					else {ChordToExtended Element}|{DroneTransformation Element NBR-1}
					end
				[]H then
					if NBR==0 then nil
					else {NoteToExtended Element}|{DroneTransformation Element NBR-1}
					end
				end
			end

			%Attention prend un float en argument
			fun{StretchTransformation F P}
				case P
				of nil then nil
				[] H|T then
					if {IsExtendedChord H} then
						{StretchTransformation F H}|{StretchTransformation F T}
					else
						case H
						of note(name:N octave:O sharp:S duration:D instrument:I) then
							note(name:N octave:O sharp:S duration:(D*F) instrument:I)|{StretchTransformation F T}
						else error(cause:H comment:noteItemNoDetected)
						end
					end
				else error(cause:P comment:wrongInput)
				end
			end

			fun{TransposeTransformation ST P}
				case P
				of nil then nil
				[] H|T then
					if {IsExtendedChord H} then
						{TransposeTransformation ST H}|{TransposeTransformation ST T}
					else {TransposeNote ST H}|{TransposeTransformation ST T} end
				else error(cause:P comment:noteAPartition) end
			end
		in
			case Tr 
			of duration(seconds:S P) then 
				{DurationTransformation S {PartitionConvert P}}
			[] stretch(factor:F P) then
				{StretchTransformation F {PartitionConvert P}}
			[] drone(note:N amount:A) then
				{DroneTransformation N A}
			[] transpose(semitones:SN P) then
				{TransposeTransformation SN {PartitionConvert P}}
			else erreur(content:Tr comment:erreur_dans_la_fonction_tranformation_convert) 
			end
		end

		%Retourn si N est au format d une note
		fun{IsNote N}
			case N
			of Name#Octave then true
			[] Atom then
				if Atom == silence then true
				elseif {Record.toListInd Atom $}\=nil then false
				elseif {Record.toListInd Atom $}==nil then
					if {VirtualString.length Atom $}\=1 andthen {VirtualString.length Atom $}\=2 then false
					else true 
					end
				else false
				end
			else false 
			end
		end
		
		%Retourn si N est au format d un accord
		fun{IsChord C}
			case C of nil then true
			[] H|T then if {IsNote H}==false then false else {IsChord T} end
			else false
			end
		end
		

		fun{IsTransformation T}
			case T 
			of duration(seconds:D 1:P) then true
			[]stretch(factor:F P) then true
			[]drone(note:N amount:A) then true
			[]transpose(semitones:SN P)then true
			else false end 
		end

		%Convertit une partition en une flatPartition
		fun{PartitionConvert Partition}
			case Partition 
			of nil then nil
			[] H|T then
				if {IsNote H} then {NoteToExtended H}|{PartitionConvert T}
				elseif {IsChord H} then {ChordToExtended H}|{PartitionConvert T}
				elseif {IsExtendedNote H} then H|{PartitionConvert T}
				elseif {IsExtendedChord H} then H|{PartitionConvert T} 
				elseif {IsTransformation H} then
					{Append {TransformationConvert H} {PartitionConvert T}}
				else error(cause:H comment:partitionItemNoDetected)
				end
			else error(cause:Partition comment:partitionCOnvert)
			end
		end
	in
		{PartitionConvert Partition}
	end
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Mix P2T Music}
	%PAS EN COMMENTAIRE DANS LE CANNEVA DE BASE

		%retourne true si S est au format d'un Samples
		%dans le cas contraire, il retourne false
      LissageDuration=0.01

      fun{IsSamples S}
	 case S of nil then true
	 []H|T then 
	    if{Number.is H $}==false then false
	    else {IsSamples T}
	    end
	 else false
	 end
      end

		%retourne true si l input peut potentiellement etre un liens vers un fichier. (on ne vereifie pas ici si le fichier existe) 
		%retourne false dans le cas contraire
      fun{IsWave W}
	 {Atom.is W $}
      end

		%EST FAUT
		%fun{IsPartitionOlc P}
		%	case P of nil then true
		%	[]H|T then 
		%		if {IsExtendedChord H}==false andthen {IsExtendedNote H}==false then false
		%		else{IsPartition T}
		%		end
		%	else false
		%	end
		%end

		%NE SERT A RIEN
		%fun{IsPartition P}
		%	case P of nil then true
		%	[]H|T then 
		%		if {IsExtendedChord H}==false 
		%			andthen {IsExtendedNote H}==false 
		%			andthen {IsNote H}==false 
		%			andthen {IsChord H} 
		%			andthen {IsTransformation H}==false
		%			then false
		%		else{IsPartition T}
      %%		end
		%	else false
		%	end
		%end

		%retourne true si l input est un Filte
		%retourne false dans le cas contraire
      fun{IsFilter F}
	 case F of reverse(A) then true
	 [] repeat(amount:R M) then true
	 [] loop(duration:D M) then true
	 [] clip(low:S1 high:S2 M) then true
	 [] echo(delay:D decay:F M)then true
	 [] fade(start:D1 out:D2 M) then true
	 [] cut(start:D1 finish:D2 M) then true
	 else false
	 end
      end

		%Retourne la hauteur d une note
      fun{GetHauteur N}
	 fun{GetHauteurBis N Fac Acc}
	    if N.name ==a andthen N.octave ==4 then Acc
	    else {GetHauteurBis {TransposeNote Fac*(~1) N} Fac Acc+Fac}
	    end
	 end
      in
			%le -1 correcpond au fait que la note se trouve en dessous de a4, le 1 correspond au fait que la note se trouve au dessus de a4
	 if N.octave<4 then {GetHauteurBis N ~1 0}
	 elseif N.octave>4 then {GetHauteurBis N 1 0}
	 elseif N.name<c then {GetHauteurBis N 1 0}
	 elseif N.name>b  then {GetHauteurBis N ~1 0}
	 end
      end

		%retourn un echantillon/sample d une note N et un I (qui est l'index qui permet de faire evoluer le signal sous forme d un sinus)
		%retourn un  0<= float <=1
		%l input I est un integer
      fun{GetEchantillon N I}
	 H F PI 
      in 
	 PI=3.14159265359
	 H={Int.toFloat {GetHauteur N}}
	 F={Number.pow 2.0 H/12.0}*440.0
	 0.5*{Float.sin (2.0*PI*F*{Int.toFloat I}/44100.0)}
      end

		%retourn une liste mais sans le nil avec "Acc" foi Element
		%Acc est un integer
      fun{GetNTime Element Acc}
	 if Acc==1 then Element
	 else Element|{GetNTime Element Acc-1}
	 end
      end

		%retourn une liste avec tout les echantillons correspondants a la note "Note"
      fun{GetNoteEchantillons Note IStart}
			%retourn une liste les echantillons d une note
	 fun{ListOfNTimeEchantillon N I}
	    if {Float.toInt (N.duration*44100.0)}+IStart < I then nil
	    else {GetEchantillon N I}|{ListOfNTimeEchantillon N I+1}
	    end
	 end
      in
	 case Note of silence(duration:D) then  {GetNTime 0 {Float.toInt D*44100.0}}
	 []note(name:N octave:O sharp:S duration:D instrument:I) then {Fade LissageDuration LissageDuration {ListOfNTimeEchantillon Note IStart}}
	 else error(cause:Note comment:input_non_error_dans_echantillion)
	 end
      end

		%retourn une liste qui est la somme des deux liste
		%L1 et L2 doivent etre de la meme longueur
      fun{SumTwoList L1 L2}
	 case L1 of nil then nil
	 [] H|T then L1.1+L2.1|{SumTwoList T L2.2}
	 end 	
      end

		%retourne la partition convertie en un Samples (Liste de sample)
		%index est un integer
      fun{PartitionToSample Partition Index}
	 case Partition 
	 of nil then nil 
	 []H|T then
	    case H 
	    of M1|M2 then % c est un chord
	       local
						%retourne les echantioons d un chord
						%Acc est un integer
		  fun{SumChordSample Chord Acc} %fait la somm
		     case Chord 
		     of H1|nil  then 
			if Acc==0 then 
			   {GetNoteEchantillons H1 Index}
			else {SumTwoList Acc {GetNoteEchantillons H1 Index}}
			end
		     [] H1|T1 then 
			if Acc==0 then 
			   {SumChordSample T1 {GetNoteEchantillons H1 Index}}
			else {SumChordSample T1 {SumTwoList Acc {GetNoteEchantillons H1 Index}}} 
			end
		     end
		  end

	       in
		  {Append {SumChordSample H 0} {PartitionToSample T Index+{Float.toInt M1.duration*44100.0}}}
	       end
	    [] M1 then %c est une note OK
	       {Append {GetNoteEchantillons H 0} {PartitionToSample T Index+{Float.toInt M1.duration*44100.0}}}
	    else error
	    end
	 else error(cause:Partition comment:partitionToSampleElse)
	 end 
      end


		%retour une liste de Sammple qui provienne du fichier Wave
		%Le fichier Wave doit exister
      fun{WaveToSample Wave}
	 {Project.readFile Wave}
		   
      end

		%retourn une liste d echantillons/sample
      fun{FilterToSample Filter}

			%retourn une la liste L mais inverse
			%Acc est un integer
	 fun{Reverse L Acc}
	    case L of nil then Acc
	    []H|T then {Reverse T H|Acc}
	    end
	 end

			%repete "A" foi la liste M
			%retourn une liste dechantillons 
	 fun{Repeat A M}
	    if A==0 then nil
	    else {Append M {Repeat A-1 M}}
	    end
	 end

			%repete la list OldL de sorte d avoir une liste de "NbrElement" element. 
			%retourn une liste 
			%OldL et L doivent etre les meme
	 fun{Loop OldL L NbrElement}
	    case L 
	    of nil then 
	       if NbrElement\=0 then {Loop OldL OldL NbrElement}
	       else nil
	       end
	    []H|T andthen NbrElement\=0 then H|{Loop OldL T NbrElement-1}
	    else nil
	    end
	 end

			%retourne les  elements de la liste entre Start et Finish-1
			%prend de Start compris a Finish noncompris
			%index commence a 0
			%Start et Finish sont des integer
	 fun{Cut Start Finish M}
	    case M 
	    of nil then
	       if Start >0 then {Cut 0 Finish-Start nil}
	       elseif Start==0 andthen Finish >0 then 0|{Cut Start Finish-1 nil}
	       else nil
	       end
	    [] H|T then 
	       if Start==0 andthen Finish >0 then H|{Cut Start Finish-1 T}
	       elseif Start==0 andthen Finish==0 then nil
	       elseif Start>0 then {Cut Start-1 Finish-1 T}
	       end

	    end
	 end

			%retourne une liste d echantillons entre Low et High
			%les elements de la liste plus petit que low sont ramenes a low et ceux plus haut que hight sont ramene a high
			%Low et High sont des Float
	 fun{Clip Low High Echantillon}
	    case Echantillon of nil then nil
	    [] H|T then
	       if H>High then High|{Clip Low High T}
	       elseif H<Low then Low|{Clip Low High T}
	       else H|{Clip Low High T}
	       end
	    end
	 end

			%retourne une liste d echantillons avec un fondu d entree de "SDuration" secondes
			%et un fondu de sortie de "FDuration" secondes
			%M0 est une liste d echantillons
			
      in
	 case Filter
	 of reverse(M) then {Reverse {MixConvert M} nil}
	 [] repeat(amount:R M) then {Repeat R {MixConvert M}}
	 [] loop(duration:D M) then
	    local L={MixConvert M}
	    in {Loop  L L D*44100}
	    end
	 [] clip(low:S1 high:S2 M) then {Clip S1 S2 {MixConvert M}}
	 [] echo(delay:D decay:F M)then true
	 [] fade(start:D1 out:D2 M) then {Fade D1 D2 {MixConvert M}}
	 [] cut(start:D1 finish:D2 M) then {Cut D1*44100 D2*44100+1 {MixConvert M}}
	 else error(cause:Filter comment:filtreNonReconnu)
	 end
      end

      fun{Fade SDuration FDuration M0}
	 X1=1.0/(SDuration*44100.0)
				%applique un fondu d entree sur les "NbrElement" premiers elements a la liste M
	 fun{ApplyEntree NbrElement M}
	    case M of nil then nil
	    []H|T then
	       if NbrElement\=0 then (X1*{Int.toFloat ({Float.toInt SDuration*44100.0} - NbrElement)})*H|{ApplyEntree NbrElement-1 T}
	       else H|{ApplyEntree NbrElement T}
	       end
	    end
	 end

	 X2=1.0/(FDuration*44100.0)
				
				%applique un fondu de sortie sur les "NbrElement" derniers elements a la liste M
				%Acc est un Integer
	 fun{ApplySortie NbrElement M Acc}
	    case M of nil then nil
	    []H|T then
	       if Acc==0 then H*(X2*{Int.toFloat NbrElement})|{ApplySortie NbrElement-1 T Acc} 
	       else H|{ApplySortie NbrElement T Acc-1}
	       end 
	    end
	 end
	 M1
      in
	 if SDuration \=0.0 andthen FDuration \=0.0 then 
	    M1={ApplyEntree {Float.toInt SDuration*44100.0} M0}
	    {ApplySortie {Float.toInt FDuration*44100.0} M1 {List.length M0}-{Float.toInt FDuration*44100.0}-1}
	 elseif SDuration ==0.0 andthen FDuration \=0.0 then
	    {ApplySortie {Float.toInt FDuration*44100.0} M0 {List.length M0}-FDuration*44100.0}
	 elseif SDuration \=0.0 andthen FDuration ==0.0 then
	    {ApplyEntree {Float.toInt SDuration*44100.0} M0}
	 else
	    M0
	 end
      end

		%FONCTION  MAIN 
		%retourne une liste d echantillons
		%retourne un Samples
      fun{MixConvert M}
	 case M of nil then nil
	 []H|T then
	    case H of samples(S) then {Append S {MixConvert T}}
	    [] partition(P) then {Append {PartitionToSample {P2T P} 1} {MixConvert T}}
	    [] wave(W) then {Append {WaveToSample W} {MixConvert T}}
	    [] merge(MI) then error(merge_pas_encore_pret)
	    else
	       if {IsFilter H} then {Append {FilterToSample H} {MixConvert T}}
	       else error(cause:H comment:cas_Pas_encore_pris_en_charge)
	       end
	    end 		
	 end
      end

   in
      if Music==nil then nil
      else {MixConvert Music}
      end
   end
		
   Start
   \insert 'C:/Users/olivi/Documents/GitHub/Projet_Info_2018/tests.oz'
in
   Start = {Time}

	% Uncomment next line to run your tests.
	% {Test Mix PartitionToTimedList
	
	% Add variables to this list to avoid "local variable used only once"
	% warnings.
	%PAS EN COMMENTAIRE DANS LE CANNEVA DE BASE 
	%{ForAll [NoteToExtended Music] Wait}
   
  
	
   {Browse debut}
   local
     % Music=[wave('C:/Users/Olivier/Documents/Projet_Info_2018/chicken.wav')]
      M2={Project.load 'C:/Users/olivi/Documents/GitHub/Projet_Info_2018/joy.dj.oz'}
      M1=[partition([note(name:a octave:4 sharp:false duration:1.0 instrument:piano)])]
      M3={BackToTheFutur}
    
   in

      {Browse {Project.run Mix PartitionToTimedList M3 'C:/Users/olivi/Documents/GitHub/Projet_Info_2018/out.wav' $}}
   end
   	%{TestP2T PartitionToTimedList}
	%{TestMix PartitionToTimedList MI}
	%{Test Mix PartitionToTimedList}
   {Browse fin}
	% Shows the total time to run your code.
   {Browse {IntToFloat {Time}-Start} / 1000.0}
end
