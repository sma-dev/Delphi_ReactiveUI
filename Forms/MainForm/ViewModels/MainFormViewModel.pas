Unit MainFormViewModel;

Interface

Uses LiveData, SysUtils, MainFormTypes;

Type
  TMainFormStates = (InputParamState, InputArrayState, ShowResultState);
  ////////////////////////////////
  TMainFormActions = (ShowErrorMessage, ClearAll);
  ////////////////////////////////
  TMainFormUIState = Class(TObject)
    Private
      { Private declarations }
      mState : TMainFormStates;
      mData : TObject;
    Published
      { RTTI declarations }
    Public
      { Public declarations }
      property State : TMainFormStates read mState;
      property Data : TObject read mData;
      constructor Create(Data : TObject; State : TMainFormStates);
  End;
  ////////////////////////////////
  TMainFormUIAction = Class(TObject)
    Private
      { Private declarations }
      mAction : TMainFormActions;
      mData : TObject;
    Published
      { RTTI declarations }
      property Action : TMainFormActions read mAction;
      property Data : TObject read mData;
      constructor Create(Data : TObject; Action : TMainFormActions);
    Public 
      { Public declarations }
  End;
  ////////////////////////////////
  // Define ViewModel class
  TMainFormViewModel = Class(TObject)
    Private
      { Private declarations } 
      mTag : String;
      mViewStatesLiveData : TLiveData;
      mViewActionsLiveData : TLiveData;
    Published
      { RTTI declarations }
      // ViewModel properties
      property Tag : String read mTag;
      property ViewStatesLiveData : TLiveData read  mViewStatesLiveData;
      property ViewActionsLiveData : TLiveData read  mViewActionsLiveData;
      // ViewModel functions
      Procedure SubmitParamsInput(Nx: Integer; B: Real; C: Real);
      Procedure Calculate(InputArray : TarrayOfReal);
      Procedure EditInputParams();
      Procedure ClearAll();
      // ViewModel constructor
      constructor Create(tag : String);
    Public 
      { Public declarations }
  End;

Implementation

constructor TMainFormViewModel.Create(tag : String);
Begin
  mTag := tag;
  mViewStatesLiveData := TLiveData.Create('ViewStates');
  mViewStatesLiveData.SetValue(TMainFormUIState.Create(nil, InputParamState));
  mViewActionsLiveData := TLiveData.Create('ViewActions');
End;

constructor TMainFormUIState.Create(Data : TObject; State : TMainFormStates);
Begin
  mData := Data;
  mState := State;
End;

constructor TMainFormUIAction.Create(Data : TObject; Action : TMainFormActions);
Begin
  mData := Data;
  mAction := Action;
End;

Procedure TMainFormViewModel.SubmitParamsInput(Nx: Integer; B: Real; C: Real);
Var
  dto : TMainFormArrayDto;
begin
  // TODO Add params validation
  if Nx <= 0 Then
    self.mViewActionsLiveData.SetValue(TMainFormUIAction.Create(TString.Create('Array length <= 0'), ShowErrorMessage))
  else begin
    dto := TMainFormArrayDto.Create;
    dto.Nx := Nx;
    dto.B := B;
    dto.C := C;
    self.mViewStatesLiveData.SetValue(TMainFormUIState.Create(dto, InputArrayState));
  end;
end;

Procedure TMainFormViewModel.Calculate(InputArray : TarrayOfReal);
Var
  dto : TMainFormArrayDto;
  Temp: Real;
  i, j, yn, DivCount: Integer;
begin
  // TODO Add input array validation
  if mViewStatesLiveData.GetValue() is TMainFormUIState Then
    if (mViewStatesLiveData.GetValue() as TMainFormUIState).Data is TMainFormArrayDto Then begin
      With (mViewStatesLiveData.GetValue() as TMainFormUIState).Data as TMainFormArrayDto do begin
        X := InputArray;
        If B > C Then Begin
          Temp := B;
          B := C;
          C := Temp;
        End;
        DivCount := 0;
        yn := 0;
        For i:=0 To Nx-1 Do Begin
          If (DivCount < 2) And (Frac(X[i]) = 0) And (Trunc(X[i]) Mod 3 = 0) Then Begin
            Inc(DivCount);
            If DivCount = 2 Then DivElem := X[i];
          End;
          If (X[i]<B) Or (X[i]>C) Then Inc(yn);
        End;
        If DivCount = 2 Then
          //Writeln('Второй элемент массива, кратный 3 =', FormatFloat('0.0',DivElem): 6)
        Else
          //Writeln('Нет второго элемента, кратного 3.');
        SetLength(Y, yn);
        j := 0;
        For i:=0 To Nx-1 Do Begin
          If (X[i]<B) Or (X[i]>C) Then Begin
            Y[j] := X[i];
            Inc(j);
          End;
        End;
      end;
      self.mViewStatesLiveData.SetValue(TMainFormUIState.Create((mViewStatesLiveData.GetValue() as TMainFormUIState).Data, ShowResultState));
    end;
end;

Procedure TMainFormViewModel.EditInputParams();
Var
  dto : TMainFormArrayDto;
begin
  self.mViewStatesLiveData.SetValue(TMainFormUIState.Create((mViewStatesLiveData.GetValue() as TMainFormUIState).Data, InputParamState));
end;

Procedure TMainFormViewModel.ClearAll();
Var
  dto : TMainFormArrayDto;
begin
  self.mViewStatesLiveData.SetValue(TMainFormUIState.Create(nil, InputParamState));
end;

(*Procedure TMainFormViewModel.Calculate();
var
  X, Y: TarrayOfReal;
  B, C, Temp, DivElem: Real;
  i, j, n, yn, DivCount: Integer;
  ResultDto: TResultDto;
begin
  with mArrayParamsLiveData.GetValue() As TArrayParamsDto do
   begin
    n := Nx;
    B := B;
    C := C;
   end;

   X := (mInputArrayLiveData.GetValue() as TInputArrayDto).X;

 
  If B > C Then
    Begin
      Temp := B;
      B := C;
      C := Temp;
    End;
  SetLength(X, n);
  DivCount := 0;
  yn := 0;
  For i:=0 To n-1 Do
    Begin
      If (DivCount < 2) And (Frac(X[i]) = 0) And (Trunc(X[i]) Mod 3 = 0)
        Then
        Begin
          Inc(DivCount);
          If DivCount = 2 Then DivElem := X[i];
        End;
      If (X[i]<B) Or (X[i]>C) Then Inc(yn);
    End;
  If DivCount = 2 Then
    Writeln('Второй элемент массива, кратный 3 =', FormatFloat('0.0',DivElem): 6) Else
    Writeln('Нет второго элемента, кратного 3.');
  SetLength(Y, yn);
  j := 0;
  For i:=0 To n-1 Do
    Begin
      If (X[i]<B) Or (X[i]>C) Then
        Begin
          Y[j] := X[i];
          Inc(j);
        End;
    End;
  ResultDto := TResultDto.Create();
  ResultDto.Y := Y;
  ResultDto.DivElem := DivElem;
  mResultLiveData.SetValue(TDataValidState.Create(ResultDto));
end;*)

End.
