local
	% See project statement for API details.
	%[Project] = {Link ['Project2018.ozf']}
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	fun {PartitionToTimedList Partition} 

		fun{TransformationConvert Tr}

		    %Modifie la durÃ©e des Ã©lements de la FlatPartition par Duration
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
      				if NBR==1 then {NoteToExtended Element}
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
      		in
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

		%Retourn si N est au format d'une note
		fun{IsNote N}
         case N
         of Name#Octave then true
         [] Atom then
            local B in
               if Atom == silence then true
               elseif {Record.toListInd Atom $}\=nil then false
               elseif {Record.toListInd Atom $}==nil then
                  if {VirtualString.length Atom $}\=1 andthen {VirtualString.length Atom $}\=2 then false
                  else true 
                  end
               else false
               end
            end
         else false 
         end
      end
   
		%Retourn si N est au format d'un accord
		fun{IsChord C}
			case C of nil then true
			[] H|T then if {IsNote H}==false then false else {IsChord T} end
			else false
			end
		end
	  
		%Retourn si N est au format d'une extended note
		fun{IsExtendedNote EN}
			case EN of silence(duration:D) then true
			[] note(name:N octave:O sharp:S duration:D instrument:I) then true
			else false
			end
		end
	  
		%Retourn si N est au format d'un extended chord
		fun{IsExtendedChord EC}
			case EC of nil then true
			[]H|T then if {IsExtendedNote H}==false then false else {IsExtendedChord T} end
			else false
			end
		end

		fun{IsTransformation T}
      	case T 
      	of duration(seconds:D 1:P) then true
      	[]stretch(factor:F P) then true
      	[]drone(note:N amount:A) then true
      	[]transpose(seminotes:SN P)then true
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
					{TransformationConvert H}|{PartitionConvert T}
				else error(cause:H comment:partitionItemNoDetected)
            end
			end
		end
	in
		{PartitionConvert Partition}
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Mix P2T Music}
   	%PAS EN COMMENTAIRE DANS LE CANNEVA DE BASE
      %{Project.readFile 'wave/animaux/cow.wav'}

      %retourne si l'input est un Samples:= Tableau de Sample
      fun{IsSamples S}
        case S of nil then true
        []H|T then 
          if{Number.is H $}==false then false
          else {IsSamples T}
          end
        else error(cause:S comment:forat_de_samples)
        end
      end

      %retourn si l'input est un atom => correspond un input de type lien de fichier
      fun{IsWave W}
        {Atom.is W $}
      end

      %retourn si l'input est un Filte
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

      %Retourne la hauteur d'une note
      %fac == -1 si la note est en dessou de a4 et ==1 si au dessus de a4
      fun{GetHauteur N}
        fun{GetHauteurBis N Fac Acc}
            if N.name==a andthen N.octave==4 then Acc
            else
              {GetHauteurBis {TransposeNote Fac*(~1) N} Fac Acc+Fac}
            end
        end
      in
        if EN.octave<4 then {GetHauteurBis N ~1 0}
        elseif EN.octave>4 then {GetHauteurBis N 1 0}
        elseif EN.name<c then {GetHauteurBis N 1 0}
        elseif EN.name>b  then {GetHauteurBis N ~1 0}
        end
      end

      %retoure l'échantillon de la note
      %retourn sous la forme d'un enregistrement '|'(_ _) / list sans le nil 
      fun{GetEchantillons N IStart}
         fun{GetEchantillon N I}
            H F PI 
         in 
            PI=3.14159265359
            H={GetHauteur N}
            F={Number.pow 2 H/12 $}
            1/2*{Float.sin (2*PI*F*I/44100) $}
         end
         fun{ListOfNTimeEchantillon N I}
            if {Float.toInt (N.duration*44100.0+IStart) $} == I then {GetEchantillon N I}
            else {GetEchantillon N I}|{ListOfNTimeEchantillon N I+1}
            end
         end
      in
         case N of silence(duration:D) then
            local
               fun{GetNTime Element Acc}
                  if Acc==1 then Element
                  else{GetNTime Element Acc-1}
                  end
               end
            in
               {GetNTime 0 D*44100}
            end
         []note(name:N octave:O sharp:S duration:D instrument:I) then {ListOfNTimeEchantillon N 0}
         end
      end


      %FONCTION  MAIN 
      fun{MixConvert M}
         nil
      end

   in
      if Music==nil then nil
      else
         {MixConvert Music}
      end

   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %PAS EN COMMENTAIRE DANS LE CANNEVA DE BASE
   %Music = {Project.load 'joy.dj.oz'}
   Start

   % Uncomment next line to insert your tests.
   % \insert 'tests.oz'
   % !!! Remove this before submitting.
in
   	Start = {Time}

	% Uncomment next line to run your tests.
	% {Test Mix PartitionToTimedList}

   	% Add variables to this list to avoid "local variable used only once"
   	% warnings.
	%PAS EN COMMENTAIRE DANS LE CANNEVA DE BASE 
      %{ForAll [NoteToExtended Music] Wait}
   
   	% Calls your code, prints the result and outputs the result to `out.wav`.
   	% You don't need to modify this.
	%PAS EN COMMENTAIRE DANS LE CANNEVA DE BASE
      %{Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}

  
  %**********TEST*****************  
   local 
      proc{Test}
         N1 C1 EN1 N2 C2 T T2 P T3 P2 T4
            in
         N1=a3
         C1=[a b#4]
         N2=e
         EN1=note(name:c octave:4 sharp:true duration:4 instrument:piano)
         T=duration(seconds:3.0 [N1 N2])
         T2=drone(note:C1 amount:2)
        T3=stretch(factor:2.0 [N1])
        T4=transpose(seminotes:3 [C1])
         P=[N1 C1 N2 EN1 T T2]
         P2=[T]
         {Browse {PartitionToTimedList P2}}
      end
   in
      %{TestDroneTransformation}
      {Test}
   end
   	% Shows the total time to run your code.
   	{Browse {IntToFloat {Time}-Start} / 1000.0}
end
