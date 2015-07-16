with SDL;
with SDL.Error;
with SDL.Events.Events;
with SDL.Events.Keyboards;
with SDL.Events.Joysticks;
with SDL.Log;
with SDL.Video.Windows;
with SDL.Versions;
with System;

procedure Test is
   W              : SDL.Video.Windows.Window;
   Total_Drivers  : Positive := SDL.Video.Total_Drivers;
   Linked_Version : SDL.Versions.Version;
begin
   SDL.Log.Set (Category => SDL.Log.Application, Priority => SDL.Log.Debug);

   SDL.Versions.Linked_With (Info => Linked_Version);

   SDL.Log.Put_Debug ("System.Word_Size: " & Integer'Image (System.Word_Size));
   SDL.Log.Put_Debug ("Revision        : " & SDL.Versions.Revision);
   SDL.Log.Put_Debug ("Linked with     : " & SDL.Versions.Version_Level'Image (Linked_Version.Major) &
                        "." & SDL.Versions.Version_Level'Image (Linked_Version.Minor) &
                        "." & SDL.Versions.Version_Level'Image (Linked_Version.Patch));
   SDL.Log.Put_Debug ("Compiled with   : " & SDL.Versions.Version_Level'Image (SDL.Versions.Compiled_Major) &
                        "." & SDL.Versions.Version_Level'Image (SDL.Versions.Compiled_Minor) &
                        "." & SDL.Versions.Version_Level'Image (SDL.Versions.Compiled_Patch));
   SDL.Log.Put_Debug ("Bit Order       : " & System.Bit_Order'Image (SDL.Video.Windows.Window'Bit_Order));
   SDL.Log.Put_Debug ("Total drivers   : " & Positive'Image (Total_Drivers));

   for Index in Positive'First .. Total_Drivers loop
      SDL.Log.Put_Debug ("Driver (" & Positive'Image (Index) & ")     : " & SDL.Video.Driver_Name (Natural (Index)));
   end loop;

   if SDL.Initialise = True then
      SDL.Log.Put_Debug ("Current driver  : " & SDL.Video.Current_Driver_Name);
      SDL.Log.Put_Debug ("Total displays  : " & Positive'Image (SDL.Video.Total_Displays));

      SDL.Error.Clear;

      SDL.Log.Put_Debug ("Error           : " & SDL.Error.Get);

      W.Create (Title => "Test SDLAda 2.0 - हिन्दी समाचार", X => 100, Y => 100, Width => 800, Height => 640);

      SDL.Log.Put_Debug ("Window Grabbed  : " & Boolean'Image (W.Is_Grabbed));

      --  W.Set_Grabbed;

      SDL.Log.Put_Debug ("Window Grabbed  : " & Boolean'Image (W.Is_Grabbed));
      SDL.Log.Put_Debug ("Window ID       : " & SDL.Video.Windows.ID'Image (W.Get_ID));
      SDL.Log.Put_Debug ("Window Title    : " & W.Get_Title);

      --  W.Set_Mode (SDL.Video.Windows.Full_Screen);

      declare
         ID : SDL.Video.Windows.ID     := SDL.Video.Windows.Get_ID (W);
         W2 : SDL.Video.Windows.Window := SDL.Video.Windows.From_ID (ID);
      begin
         SDL.Video.Windows.Set_Title (W2, "Grabbed second window!");
      end;

      declare
         Event    : SDL.Events.Events.Events;
         Finished : Boolean := False;

         use type SDL.Events.Event_Types;
         use type SDL.Events.Keyboards.Key_Codes;
      begin
         loop
            while SDL.Events.Events.Poll (Event) loop
               case Event.Common.Event_Type is
                  when SDL.Events.Quit =>
                     Finished := True;

                  when SDL.Events.Keyboards.Key_Up =>
                     SDL.Log.Put_Debug ("Key up event    : " &
                                          SDL.Events.Keyboards.Key_Codes'Image (Event.Keyboard.Key_Sym.Key_Code) &
                                          "    Scan code: " &
                                          SDL.Events.Keyboards.Scan_Codes'Image (Event.Keyboard.Key_Sym.Scan_Code));

                     if Event.Keyboard.Key_Sym.Key_Code = SDL.Events.Keyboards.Code_Escape then
                        Finished := True;
                     end if;

                  when SDL.Events.Joysticks.Axis_Motion =>
                     SDL.Log.Put_Debug
                       ("Joystick axis event (ID = " & SDL.Events.Joysticks.IDs'Image (Event.Joystick_Axis.Which) &
                          "): Axis: " & SDL.Events.Joysticks.Axes'Image (Event.Joystick_Axis.Axis) &
                          "    Value: " & SDL.Events.Joysticks.Axes_Values'Image (Event.Joystick_Axis.Value));

                  when others =>
                     null;
               end case;
            end loop;

            exit when Finished;
         end loop;
      end;

      W.Finalize;
      SDL.Finalise;
   end if;
end Test;
