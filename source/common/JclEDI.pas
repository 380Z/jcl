{**************************************************************************************************}
{                                                                                                  }
{ Project JEDI Code Library (JCL)                                                                  }
{                                                                                                  }
{ The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License"); }
{ you may not use this file except in compliance with the License. You may obtain a copy of the    }
{ License at http://www.mozilla.org/MPL/                                                           }
{                                                                                                  }
{ Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF   }
{ ANY KIND, either express or implied. See the License for the specific language governing rights  }
{ and limitations under the License.                                                               }
{                                                                                                  }
{ The Original Code is JclEDI.pas.                                                                 }
{                                                                                                  }
{ The Initial Developer of the Original Code is documented in the accompanying                     }
{ help file JCL.chm. Portions created by these individuals are Copyright (C) of these individuals. }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ Contains classes to eaisly parse EDI documents and data. Variable delimiter detection allows     }
{ parsing of the file without knowledge of the standards at an Interchange level.  This allows     }
{ parsing and construction of EDI documents with different delimiters.  Various EDI  file errors   }
{ can also be detected.                                                                            }
{                                                                                                  }
{ Unit owner:    Raymond Alexander                                                                 }
{ Last modified: March 2, 2003                                                                     }
{ Additional Info:                                                                                 }
{   E-Mail at RaysDelphiBox3@hotmail.com                                                           }
{   Help and Demos at http://24.54.82.216/DelphiJedi/Default.htm                                   }
{    My website is usually available between 8:00am-10:00pm EST                                    }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ 01/02/2003 to 04/01/2003 (R.A.)                                                                  }
{                                                                                                  }
{   I hope to have the utility/demos and some updated help files available for download soon.      }
{                                                                                                  }
{   - New Utility/Demos based on new classes.                                                      }
{                                                                                                  }
{       EDI Specification Manager Demo (1.0.0.9)                                                   }
{       EDI Data Tree Demo (version 1.0.0.11)                                                      }
{                                                                                                  }
{   - New Classes and Types                                                                        }
{                                                                                                  }
{      * TEDIDataObjectDataState = (ediCreated, ediAssembled, ediDissassembled);                   }
{      * TEDITransactionSetSegmentSTSpec = class(TEDITransactionSetSegmentSpec)                    }
{      * TEDIFunctionalGroupSegmentGSSpec = class(TEDIFunctionalGroupSegmentSpec)                  }
{      * TEDITransactionSetSpec = class(TEDITransactionSet)                                        }
{      * TEDIFunctionalGroupSpec = class(TEDIFunctionalGroup)                                      }
{      * TEDIInterchangeControlSpec = class(TEDIInterchangeControl)                                }
{      * TEDITransactionSetLoop = class(TEDIDataObject)                                            }
{      * TEDILoopStackRecord = record                                                              }
{      * TEDILoopStackArray = array of TEDILoopStackRecord                                         }
{      * TEDILoopStack = class(TObject)                                                            }
{      * TEDITransactionSetDocument = class(TEDIDataObject)                                        }
{                                                                                                  }
{        Notes:  Create a decendant class from TEDITransactionSetDocument and override the         }
{                ValidateData procedure to perform error checking.                                 }
{                                                                                                  }
{   - Updated Classes                                                                              }
{                                                                                                  }
{      * TEDIDataObjectType                                                                        }
{         - Added: ediLoop value.                                                                  }
{                                                                                                  }
{      * TEDIDataObject                                                                            }
{         - Added:                                                                                 }
{                                                                                                  }
{           protected                                                                              }
{             FState: TEDIDataObjectDataState;                                                     }
{             FCustomData1: Pointer;                                                               }
{             FCustomData2: Pointer;                                                               }
{             function Assemble: string; virtual; abstract;                                        }
{             procedure Dissassemble; virtual; abstract;                                           }
{                                                                                                  }
{           Notes:  Assemble and Dissassemble abstract procedure and function methods caused       }
{                   decendent class methods directives to change from virtual to override.         }
{                                                                                                  }
{      * TEDISegment                                                                               }
{         - Added: public procedure DeleteElement(Element: TEDIElement); overload;                 }
{                                                                                                  }
{      * TEDITransactionSet                                                                        }
{         - Added: public procedure DeleteSegment(Segment: TEDISegment); overload;                 }
{                                                                                                  }
{      * TEDIFunctionalGroup                                                                       }
{         - Added:                                                                                 }
{           public procedure DeleteTransactionSet(TransactionSet: TEDITransactionSet); overload;   }
{                                                                                                  }
{      * TEDISegmentSpec                                                                           }
{          - Added:                                                                                }
{                                                                                                  }
{            protected                                                                             }
{              procedure AssembleReservedData(ReservedData: TStrings); virtual;                    }
{              procedure DissassembleReservedData(ReservedData: TStrings); virtual;                }
{                                                                                                  }
{ 09/30/2002 (R.A.)                                                                                }
{                                                                                                  }
{   - Added new derived TEDIElementSpec & TEDISegmentSpec classes for                              }
{       EDI Specification Manager Demo (work in progress)                                          }
{       EDI Data Tree Demo (not yet released)                                                      }
{                                                                                                  }
{   - Added TEDIDataUsageType to TEDITransactionSet class.  This variable is used to control the   }
{     behavior of the TEDITransactionSet depending if is used to store data or specifications.     }
{                                                                                                  }
{   - TEDIFile now uses TFileStream File I/O instead of BlockRead/BlockWrite File I/O              }
{                                                                                                  }
{ 05/21/2002 (R.A.)                                                                                }
{                                                                                                  }
{   - Re-Tested with ANSI X12 Documents                                                            }
{                                                                                                  }
{   - Just about all code has been revised to meet jedi guide lines                                }
{                                                                                                  }
{   - Error messages have been turned into constants                                               }
{      * Some error message constants repeat so they will have to be merged                        }
{      * Possibly change error constants to resourcestrings?                                       }
{                                                                                                  }
{   - Currently working on some help file information and a demo                                   }
{                                                                                                  }
{ 05/14/2002 (R.A.)                                                                                }
{                                                                                                  }
{   - Tested with ANSI X12 Documents                                                               }
{                                                                                                  }
{ Additional Notes:                                                                                }
{                                                                                                  }
{   - Full variable delimiter length support is not available yet.  This option                    }
{     is intended to parse segments that are delimited by #13#10.                                  }
{                                                                                                  }
{                                                                                                  }
{**************************************************************************************************}

unit JclEDI;

{$I jcl.inc}

{$WEAKPACKAGEUNIT ON}

interface

uses
  SysUtils, Classes, JclBase, JclStrings, Forms, Dialogs;

//The following resource strings need to be moved to JclResources.pas
resourcestring
  EDIError075 = 'Could not get data object in transaction set loop at index [%s], Data object does not exist.';
  EDIError076 = 'Could not get data object in transaction set loop at index [%s], Index too high.';
  EDIError077 = 'Could not get data object in transaction set loop at index [%s], Index too low.';
  EDIError078 = 'Could not get data object in transaction set loop at index [%s].';
  EDIError079 = 'Could not set data object in transaction set loop at index [%s], Index too high.';
  EDIError080 = 'Could not set data object in transaction set loop at index [%s], Index too low.';
  EDIError081 = 'Could not set data object in transaction set loop at index [%s].';
  EDIError082 = 'Loop in loop stack record at index [%s] does not exist.';
  EDIError083 = 'Could not get loop stack record at index [%s], Index too high.';
  EDIError084 = 'Could not get loop stack record at index [%s], Index too low.';
  EDIError085 = 'Could not get loop stack record at index [%s].';
  EDIError086 = 'Could not get safe loop stack index [%s].';

const
  ICHSegmentId = 'ISA'; //Interchange Control Header Segment Id
  ICTSegmentId = 'IEA'; //Interchange Control Trailer Segment Id
  FGHSegmentId = 'GS';  //Functional Group Header Segment Id
  FGTSegmentId = 'GE';  //Functional Group Trailer Segment Id
  TSHSegmentId = 'ST';  //Transaction Set Header Segment Id
  TSTSegmentId = 'SE';  //Transaction Set Trailer Segment Id
  NA_LoopId = 'N/A';    //Constant used for loop id comparison
  ElementSpecId_Reserved = 'Reserved';

type
  TEDIObject = class(TObject); //Base EDI Object

  EJclEDIError = EJclError;

  TEDIDataObjectType = (ediUnknown, ediElement, ediSegment, ediLoop, ediTransactionSet,
    ediFunctionalGroup, ediInterchangeControl, ediFile, ediCustom);

  TEDIDataUsageType = (ediUseAsData, ediUseAsSpec);

  //TODO:  Work in progress
  //TEDIStandardType = (stCustom, stANSIX12, stEDIFACT);

  TEDIDataObject = class;
  TEDIElement = class;
  TEDISegment = class;
  TEDITransactionSet = class;
  TEDIFunctionalGroup = class;
  TEDIInterchangeControl = class;
  TEDIFile = class;

//--------------------------------------------------------------------------------------------------
//  EDI Delimiters Object
//--------------------------------------------------------------------------------------------------

  TEDIDelimiters = class(TObject)
  private
    FSegmentDelimiter: string;
    FElementDelimiter: string;
    FSubElementSeperator: string;
    FSegmentDelimiterLength: Integer;
    FElementDelimiterLength: Integer;
    FSubelementSeperatorLength: Integer;
    procedure SetSD(const Delimiter: string); //Segment Delimiter
    procedure SetED(const Delimiter: string); //Element Delimiter
    procedure SetSS(const Delimiter: string); //Sub Element Seperator
  public
    constructor Create; overload;
    constructor Create(const SD, ED, SS: string); overload;
    property SD: string read FSegmentDelimiter write SetSD;
    property ED: string read FElementDelimiter write SetED;
    property SS: string read FSubElementSeperator write SetSS;
    property SDLen: Integer read FSegmentDelimiterLength;
    property EDLen: Integer read FElementDelimiterLength;
    property SSLen: Integer read FSubElementSeperatorLength;
  end;

//--------------------------------------------------------------------------------------------------
//  EDI Data Object
//--------------------------------------------------------------------------------------------------

  TEDIObjectArray = array of TEDIObject;

  TEDIDataObjectArray = array of TEDIDataObject;

  TEDIDataObjectDataState = (ediCreated, ediAssembled, ediDissassembled);

  TEDIDataObject = class(TEDIObject) //EDI Data Object Base Class
  protected
    FEDIDOT: TEDIDataObjectType;
    FState: TEDIDataObjectDataState;
    FData: string;    //Raw Data
    FLength: Integer; //Length (of data)
    FParent: TEDIDataObject;
    FDelimiters: TEDIDelimiters;
    FErrorLog: TStrings;
    FCustomData1: Pointer;
    FCustomData2: Pointer;
    function GetData: string;
    procedure SetData(const Data: string);
  protected
    function Assemble: string; virtual; abstract;
    procedure Dissassemble; virtual; abstract;
  public
    constructor Create(Parent: TEDIDataObject); reintroduce;
    destructor Destroy; override;
    property CustomData1: Pointer read FCustomData1 write FCustomData1;
    property CustomData2: Pointer read FCustomData2 write FCustomData2;
  published
    property State: TEDIDataObjectDataState read FState;
    property Data: string read GetData write SetData;
    property DataLength: Integer read FLength;
    property Parent: TEDIDataObject read FParent write FParent;
    property Delimiters: TEDIDelimiters read FDelimiters write FDelimiters;
  end;

//--------------------------------------------------------------------------------------------------
//  EDI Element
//--------------------------------------------------------------------------------------------------

  TEDIElementArray = array of TEDIElement;

  TEDIElement = class(TEDIDataObject)
  public
    constructor Create(Parent: TEDIDataObject); reintroduce;
    function Assemble: string; override;
    procedure Dissassemble; override;
  end;

//--------------------------------------------------------------------------------------------------
//  EDI Element Specification
//--------------------------------------------------------------------------------------------------

  TEDIElementSpec = class(TEDIElement)
  private
    FId: string;
    FPosition: Integer;
    FDescription: string;
    FRequirementDesignator: string;
    FType: string;
    FMinimumLength: Integer;
    FMaximumLength: Integer;
  public
    function Assemble: string; override;
    procedure Dissassemble; override;
    property Id: string read FId write FId;
    property Position: Integer read FPosition write FPosition;
    property Description: string read FDescription write FDescription;
    property RequirementDesignator: string read FRequirementDesignator write FRequirementDesignator;
    property ElementType: string read FType write FType;
    property MinimumLength: Integer read FMinimumLength write FMinimumLength;
    property MaximumLength: Integer read FMaximumLength write FMaximumLength;
  end;

//--------------------------------------------------------------------------------------------------
//  EDI Segment Classes
//--------------------------------------------------------------------------------------------------

  TEDISegmentArray = array of TEDISegment;

  TEDISegment = class(TEDIDataObject)
  private
    FSegmentID: string;          //Specification: Segment ID
    FElements: TEDIElementArray; //Dissassembled raw data
    function GetElement(Index: Integer): TEDIElement;
    procedure SetElement(Index: Integer; Element: TEDIElement);
  protected
    function InternalAssignDelimiters: TEDIDelimiters; virtual;
  public
    constructor Create(Parent: TEDIDataObject); reintroduce; overload;
    constructor Create(Parent: TEDIDataObject; ElementCount: Integer); overload;
    destructor Destroy; override;
    //
    function AddElement: Integer; virtual;
    function AppendElement(Element: TEDIElement): Integer;
    function InsertElement(InsertIndex: Integer): Integer; overload; virtual;
    function InsertElement(InsertIndex: Integer; Element: TEDIElement): Integer; overload;
    procedure DeleteElement(Index: Integer); overload;
    procedure DeleteElement(Element: TEDIElement); overload;
    //
    function AddElements(Count: Integer): Integer; virtual;
    function AppendElements(ElementArray: TEDIElementArray): Integer;
    function InsertElements(InsertIndex, Count: Integer): Integer; overload; virtual;
    function InsertElements(InsertIndex: Integer;
      ElementArray: TEDIElementArray): Integer; overload;
    procedure DeleteElements; overload;
    procedure DeleteElements(Index, Count: Integer); overload;
    //
    function Assemble: string; override;
    procedure Dissassemble; override;
    property SegmentID: string read FSegmentID write FSegmentID;
    property Elements: TEDIElementArray read FElements write FElements;
    property Element[Index: Integer]: TEDIElement read GetElement write SetElement; default;
  end;

  TEDITransactionSetSegment = class(TEDISegment)
  public
    constructor Create(Parent: TEDIDataObject); reintroduce; overload;
    constructor Create(Parent: TEDIDataObject; ElementCount: Integer); overload;
    function InternalAssignDelimiters: TEDIDelimiters; override;
  end;

  TEDIFunctionalGroupSegment = class(TEDISegment)
  public
    constructor Create(Parent: TEDIDataObject); reintroduce; overload;
    constructor Create(Parent: TEDIDataObject; ElementCount: Integer); overload;
    function InternalAssignDelimiters: TEDIDelimiters; override;
  end;

  TEDIInterchangeControlSegment = class(TEDISegment)
  public
    constructor Create(Parent: TEDIDataObject); reintroduce; overload;
    constructor Create(Parent: TEDIDataObject; ElementCount: Integer); overload;
    function InternalAssignDelimiters: TEDIDelimiters; override;
  end;

//--------------------------------------------------------------------------------------------------
//  EDI Segment Specification Classes
//--------------------------------------------------------------------------------------------------

  TEDISegmentSpec = class(TEDISegment)
  private
    FPosition: Integer;
    FDescription: string;
    FSection: string;
    FRequirementDesignator: string;
    FMaximumUsage: Integer;
    FOwnerLoopId: string;
    FParentLoopId: string;
  protected
    procedure AssembleReservedData(ReservedData: TStrings); virtual;
    procedure DissassembleReservedData(ReservedData: TStrings); virtual;
  public
    function AddElement: Integer; override;
    function InsertElement(InsertIndex: Integer): Integer; override;
    function AddElements(Count: Integer): Integer; override;
    function InsertElements(InsertIndex, Count: Integer): Integer; override;

    function Assemble: string; override;
    procedure Dissassemble; override;
    property Position: Integer read FPosition write FPosition;
    property Description: string read FDescription write FDescription;
    property Section: string read FSection write FSection;
    property RequirementDesignator: string read FRequirementDesignator write FRequirementDesignator;
    property MaximumUsage: Integer read FMaximumUsage write FMaximumUsage;
    property OwnerLoopId: string read FOwnerLoopId write FOwnerLoopId;
    property ParentLoopId: string read FParentLoopId write FParentLoopId;
  end;

  TEDITransactionSetSegmentSpec = class(TEDISegmentSpec)
  public
    constructor Create(Parent: TEDIDataObject); reintroduce; overload;
    constructor Create(Parent: TEDIDataObject; ElementCount: Integer); overload;
    function InternalAssignDelimiters: TEDIDelimiters; override;
  end;

  TEDITransactionSetSegmentSTSpec = class(TEDITransactionSetSegmentSpec)
  private
    FTransactionSetId: string;
    FTSDescription: string;
  public
    procedure AssembleReservedData(ReservedData: TStrings); override;
    procedure DissassembleReservedData(ReservedData: TStrings); override;
  published
    property TransactionSetId: string read FTransactionSetId write FTransactionSetId;
    property TSDescription: string read FTSDescription write FTSDescription;
  end;

  TEDIFunctionalGroupSegmentSpec = class(TEDISegmentSpec)
  public
    constructor Create(Parent: TEDIDataObject); reintroduce; overload;
    constructor Create(Parent: TEDIDataObject; ElementCount: Integer); overload;
    function InternalAssignDelimiters: TEDIDelimiters; override;
  end;

  TEDIFunctionalGroupSegmentGSSpec = class(TEDIFunctionalGroupSegmentSpec)
  private
    FFunctionalGroupId: string;
    FFGDescription: string;
    FAgencyCodeId: string;
    FVersionReleaseId: string;
  public
    procedure AssembleReservedData(ReservedData: TStrings); override;
    procedure DissassembleReservedData(ReservedData: TStrings); override;
  published
    property FunctionalGroupId: string read FFunctionalGroupId write FFunctionalGroupId;
    property FGDescription: string read FFGDescription write FFGDescription;
    property AgencyCodeId: string read FAgencyCodeId write FAgencyCodeId;
    property VersionReleaseId: string read FVersionReleaseId write FVersionReleaseId;
  end;

  TEDIInterchangeControlSegmentSpec = class(TEDISegmentSpec)
  public
    constructor Create(Parent: TEDIDataObject); reintroduce; overload;
    constructor Create(Parent: TEDIDataObject; ElementCount: Integer); overload;
    function InternalAssignDelimiters: TEDIDelimiters; override;
  end;

//--------------------------------------------------------------------------------------------------
//  EDI Transaction Set
//--------------------------------------------------------------------------------------------------

  TEDITransactionSetArray = array of TEDITransactionSet;

  TEDITransactionSet = class(TEDIDataObject)
  private
    FSTSegment: TEDITransactionSetSegment;
    FSegments: TEDISegmentArray; //Dissassembled raw data
    FSESegment: TEDITransactionSetSegment;
    function GetSegment(Index: Integer): TEDISegment;
    procedure SetSegment(Index: Integer; Segment: TEDISegment);
    function InternalAssignDelimiters: TEDIDelimiters;
  public
    constructor Create(Parent: TEDIDataObject); reintroduce; overload;
    constructor Create(Parent: TEDIDataObject; SegmentCount: Integer); overload;
    destructor Destroy; override;

    function AddSegment: Integer;
    function AppendSegment(Segment: TEDISegment): Integer;
    function InsertSegment(InsertIndex: Integer): Integer; overload;
    function InsertSegment(InsertIndex: Integer; Segment: TEDISegment): Integer; overload;
    procedure DeleteSegment(Index: Integer); overload;
    procedure DeleteSegment(Segment: TEDISegment); overload;

    function AddSegments(Count: Integer): Integer;
    function AppendSegments(SegmentArray: TEDISegmentArray): Integer;
    function InsertSegments(InsertIndex, Count: Integer): Integer; overload;
    function InsertSegments(InsertIndex: Integer;
      SegmentArray: TEDISegmentArray): Integer; overload;
    procedure DeleteSegments; overload;
    procedure DeleteSegments(Index, Count: Integer); overload;

    function Assemble: string; override;
    procedure Dissassemble; override; 
    property SegmentST: TEDITransactionSetSegment read FSTSegment write FSTSegment;
    property SegmentSE: TEDITransactionSetSegment read FSESegment write FSESegment;
    property Segments: TEDISegmentArray read FSegments write FSegments;
    property Segment[Index: Integer]: TEDISegment read GetSegment write SetSegment; default;
  end;

//--------------------------------------------------------------------------------------------------
//  EDI Transaction Set Specification
//--------------------------------------------------------------------------------------------------

  TEDITransactionSetSpec = class(TEDITransactionSet)
  private
    FTransactionSetId: string;
    FTSDescription: string;
  published
    property TransactionSetId: string read FTransactionSetId write FTransactionSetId;
    property TSDescription: string read FTSDescription write FTSDescription;
  end;

//--------------------------------------------------------------------------------------------------
//  EDI Transaction Set Document
//--------------------------------------------------------------------------------------------------

  TEDITransactionSetLoop = class(TEDIDataObject)
  private
    FOwnerLoopId: string;
    FParentLoopId: string;
    FParentTransactionSet: TEDITransactionSet;
    //
    FEDIDataObjects: TEDIDataObjectArray;
    function GetEDIDataObject(Index: Integer): TEDIDataObject;
    procedure SetEDIDataObject(Index: Integer; EDIDataObject: TEDIDataObject);
  public
    constructor Create(Parent: TEDIDataObject); reintroduce;
    destructor Destroy; override;
    function Assemble: string; override;
    procedure Dissassemble; override;
    //
    //  ToDo:  More procedures and functions to manage internal structures
    //
    function AddLoop(OwnerLoopId, ParentLoopId: string): Integer;
    procedure AppendSegment(Segment: TEDISegment);
    procedure DeleteEDIDataObjects;
    //
    property OwnerLoopId: string read FOwnerLoopId write FOwnerLoopId;
    property ParentLoopId: string read FParentLoopId write FParentLoopId;
    property ParentTransactionSet: TEDITransactionSet read FParentTransactionSet
      write FParentTransactionSet;
    //
    property EDIDataObjects: TEDIDataObjectArray read FEDIDataObjects write FEDIDataObjects;
    property EDIDataObject[Index: Integer]: TEDIDataObject read GetEDIDataObject
      write SetEDIDataObject; default;
  end;

  TEDILoopStackRecord = record
    SegmentId: string;
    SpecStartIndex: Integer;
    OwnerLoopId: string;
    ParentLoopId: string;
    Loop: TEDITransactionSetLoop;
  end;

  TEDILoopStackArray = array of TEDILoopStackRecord;

  TEDILoopStack = class(TObject)
  private
    FEDILoopStack: TEDILoopStackArray;
    FAltStackPointer: Boolean;
    FStackResized: Boolean;
    function GetSafeStackIndex(Index: Integer): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function GetStackSize: Integer;
    function SetStackPointer(OwnerLoopId, ParentLoopId: string): Integer;
    function GetStackRecord: TEDILoopStackRecord; overload;
    function GetStackRecord(Index: Integer): TEDILoopStackRecord; overload;
    function Add(SegmentId, OwnerLoopId, ParentLoopId: string; StartIndex: Integer;
      Loop: TEDITransactionSetLoop): Integer;
    procedure UpdateLoopReference(Loop: TEDITransactionSetLoop);
    procedure Update(SegmentId, OwnerLoopId, ParentLoopId: string; StartIndex: Integer;
      Loop: TEDITransactionSetLoop);
    function Debug: string;
  published
    property Stack: TEDILoopStackArray read FEDILoopStack write FEDILoopStack;
    property AltStackPointer: Boolean read FAltStackPointer write FAltStackPointer;
    property StackResized: Boolean read FStackResized write FStackResized;
  end;

  TEDITransactionSetDocument = class(TEDITransactionSetLoop)
  private
    FErrorOccured: Boolean;
    //References
    FEDITransactionSet: TEDITransactionSet;
    FEDITransactionSetSpec: TEDITransactionSetSpec;
    //Helper Object
    FEDILoopStack: TEDILoopStack;
    //Helper functions
    function ValidateSegSpecIndex(DataSegmentId: string; SpecStartIndex: Integer;
      var LoopRepeated: Boolean): Integer;
    function ValidateLoopStack(SpecSegmentId, SpecOwnerLoopId, SpecParentLoopId: string;
      SpecStartIndex: Integer; Loop: TEDITransactionSetLoop;
      LoopRepeated: Boolean): TEDILoopStackRecord;
    function AdvanceSegSpecIndex(DataIndex, SpecStartIndex, SpecEndIndex: Integer): Integer;
  protected
    procedure ValidateData(TSDocument: TEDITransactionSetDocument;
                           LoopStack: TEDILoopStack;
                           DataSegment, SpecSegment: TEDISegment;
                           var DataIndex, SpecIndex: Integer;
                           var ErrorOccured: Boolean); virtual;
  public
    constructor Create(Parent: TEDIDataObject; EDITransactionSet: TEDITransactionSet;
      EDITransactionSetSpec: TEDITransactionSetSpec); reintroduce;
    destructor Destroy; override;
    //
    //  ToDo:  More procedures and functions to manage internal structures
    //
    procedure FormatDocument;
  protected
    property ErrorOccured: Boolean read FErrorOccured;
  end;

//--------------------------------------------------------------------------------------------------
//  EDI Functional Group
//--------------------------------------------------------------------------------------------------

  TEDIFunctionalGroupArray = array of TEDIFunctionalGroup;

  TEDIFunctionalGroup = class(TEDIDataObject)
  private
    FGSSegment: TEDIFunctionalGroupSegment;
    FTransactionSets: TEDITransactionSetArray; //Dissassembled raw data
    FGESegment: TEDIFunctionalGroupSegment;
    function GetTransactionSet(Index: Integer): TEDITransactionSet;
    procedure SetTransactionSet(Index: Integer; TransactionSet: TEDITransactionSet);
    function InternalAssignDelimiters: TEDIDelimiters;
  public
    constructor Create(Parent: TEDIDataObject); reintroduce; overload;
    constructor Create(Parent: TEDIDataObject; TransactionSetCount: Integer); overload;
    destructor Destroy; override;

    function AddTransactionSet: Integer;
    function AppendTransactionSet(TransactionSet: TEDITransactionSet): Integer;
    function InsertTransactionSet(InsertIndex: Integer): Integer; overload;
    function InsertTransactionSet(InsertIndex: Integer;
      TransactionSet: TEDITransactionSet): Integer; overload;
    procedure DeleteTransactionSet(Index: Integer); overload;
    procedure DeleteTransactionSet(TransactionSet: TEDITransactionSet); overload;

    function AddTransactionSets(Count: Integer): Integer;
    function AppendTransactionSets(TransactionSetArray: TEDITransactionSetArray): Integer;
    function InsertTransactionSets(InsertIndex, Count: Integer): Integer; overload;
    function InsertTransactionSets(InsertIndex: Integer;
      TransactionSetArray: TEDITransactionSetArray): Integer; overload;
    procedure DeleteTransactionSets; overload;
    procedure DeleteTransactionSets(Index, Count: Integer); overload;

    function Assemble: string; override;
    procedure Dissassemble; override;
    property SegmentGS: TEDIFunctionalGroupSegment read FGSSegment write FGSSegment;
    property SegmentGE: TEDIFunctionalGroupSegment read FGESegment write FGESegment;
    property TransactionSets: TEDITransactionSetArray read FTransactionSets write FTransactionSets;
    property TransactionSet[Index: Integer]: TEDITransactionSet read GetTransactionSet
      write SetTransactionSet; default;
  end;

//--------------------------------------------------------------------------------------------------
//  EDI Functional Specification
//--------------------------------------------------------------------------------------------------

  TEDIFunctionalGroupSpec = class(TEDIFunctionalGroup)
  private
    FFunctionalGroupId: string;
    FFGDescription: string;
    FAgencyCodeId: string;
    FVersionReleaseId: string;
  public
    function FindTransactionSetSpec(TransactionSetId: string): TEDITransactionSetSpec;
  published
    property FunctionalGroupId: string read FFunctionalGroupId write FFunctionalGroupId;
    property FGDescription: string read FFGDescription write FFGDescription;
    property AgencyCodeId: string read FAgencyCodeId write FAgencyCodeId;
    property VersionReleaseId: string read FVersionReleaseId write FVersionReleaseId;
  end;

//--------------------------------------------------------------------------------------------------
//  EDI Interchange Control
//--------------------------------------------------------------------------------------------------

  TEDIInterchangeControlArray = array of TEDIInterchangeControl;

  TEDIInterchangeControl = class(TEDIDataObject)
  private
    FISASegment: TEDIInterchangeControlSegment;
    FFunctionalGroups: TEDIFunctionalGroupArray; //Dissassembled raw data
    FIEASegment: TEDIInterchangeControlSegment;
    FEDIDUT: TEDIDataUsageType;
    function GetFunctionalGroup(Index: Integer): TEDIFunctionalGroup;
    procedure SetFunctionalGroup(Index: Integer; FunctionalGroup: TEDIFunctionalGroup);
  public
    constructor Create(Parent: TEDIDataObject; EDIDUT: TEDIDataUsageType = ediUseAsData);
      reintroduce; overload;
    constructor Create(Parent: TEDIDataObject; FunctionalGroupCount: Integer;
      EDIDUT: TEDIDataUsageType = ediUseAsData); overload;
    destructor Destroy; override;

    function AddFunctionalGroup: Integer;
    function AppendFunctionalGroup(FunctionalGroup: TEDIFunctionalGroup): Integer;
    function InsertFunctionalGroup(InsertIndex: Integer): Integer; overload;
    function InsertFunctionalGroup(InsertIndex: Integer;
      FunctionalGroup: TEDIFunctionalGroup): Integer; overload;
    procedure DeleteFunctionalGroup(Index: Integer);

    function AddFunctionalGroups(Count: Integer): Integer;
    function AppendFunctionalGroups(FunctionalGroupArray: TEDIFunctionalGroupArray): Integer;
    function InsertFunctionalGroups(InsertIndex, Count: Integer): Integer; overload;
    function InsertFunctionalGroups(InsertIndex: Integer;
      FunctionalGroupArray: TEDIFunctionalGroupArray): Integer; overload;
    procedure DeleteFunctionalGroups; overload;
    procedure DeleteFunctionalGroups(Index, Count: Integer); overload;

    function Assemble: string; override;
    procedure Dissassemble; override; 
    property SegmentISA: TEDIInterchangeControlSegment read FISASegment write FISASegment;
    property SegmentIEA: TEDIInterchangeControlSegment read FIEASegment write FIEASegment;
    property FunctionalGroups: TEDIFunctionalGroupArray read FFunctionalGroups
      write FFunctionalGroups;
    property FunctionalGroup[Index: Integer]: TEDIFunctionalGroup read GetFunctionalGroup
      write SetFunctionalGroup; default;
  end;

//--------------------------------------------------------------------------------------------------
//  EDI Interchange Specification
//--------------------------------------------------------------------------------------------------

  TEDIInterchangeControlSpec = class(TEDIInterchangeControl)
  public
    function FindTransactionSetSpec(FunctionalGroupId, AgencyCodeId, VersionReleaseId,
      TransactionSetId: string): TEDITransactionSetSpec;
  end;

//--------------------------------------------------------------------------------------------------
//  EDI File
//--------------------------------------------------------------------------------------------------

  TEDIFileArray = array of TEDIFile;

  TEDIFileOptions = set of (foVariableDelimiterDetection);

  TEDIFile = class(TEDIDataObject)
  private
    FFileID: Integer;
    FFileName: string;
    FInterchanges: TEDIInterchangeControlArray;
    FEDIFileOptions: TEDIFileOptions;
    //FErrorLog: TStrings;
    function GetInterchangeControl(Index: Integer): TEDIInterchangeControl;
    procedure SetInterchangeControl(Index: Integer; Interchange: TEDIInterchangeControl);
    procedure InternalLoadFromFile;
  public
    constructor Create(Parent: TEDIDataObject); reintroduce; overload;
    constructor Create(Parent: TEDIDataObject; InterchangeCount: Integer); overload;
    destructor Destroy; override;

    procedure LoadFromFile(const FileName: string);
    procedure ReLoadFromFile;
    procedure SaveToFile;
    procedure SaveAsToFile(const FileName: string);

    function AddInterchange: Integer;
    function AppendInterchange(Interchange: TEDIInterchangeControl): Integer;
    function InsertInterchange(InsertIndex: Integer): Integer; overload;
    function InsertInterchange(InsertIndex: Integer;
      Interchange: TEDIInterchangeControl): Integer; overload;
    procedure DeleteInterchange(Index: Integer);

    function AddInterchanges(Count: Integer): Integer;
    function AppendInterchanges(
      InterchangeControlArray: TEDIInterchangeControlArray): Integer;
    function InsertInterchanges(InsertIndex, Count: Integer): Integer; overload;
    function InsertInterchanges(InsertIndex: Integer;
      InterchangeControlArray: TEDIInterchangeControlArray): Integer; overload;
    procedure DeleteInterchanges; overload;
    procedure DeleteInterchanges(Index, Count: Integer); overload;

    function Assemble: string; override;
    procedure Dissassemble; override;
    property FileID: Integer read FFileID write FFileID;
    property FileName: string read FFileName write FFileName;
    property Interchanges: TEDIInterchangeControlArray read FInterchanges write FInterchanges;
    property Interchange[Index: Integer]: TEDIInterchangeControl read GetInterchangeControl
      write SetInterchangeControl; default;
    property Options: TEDIFileOptions read FEDIFileOptions write FEDIFileOptions;
  end;

//--------------------------------------------------------------------------------------------------
//  Other
//--------------------------------------------------------------------------------------------------

implementation

uses
  JclResources;

//==================================================================================================
// TEDIDelimiters
//==================================================================================================

constructor TEDIDelimiters.Create;
begin
  inherited Create;
  FSegmentDelimiter := '';
  FElementDelimiter := '';
  FSubElementSeperator := '';
  FSegmentDelimiterLength := 0;
  FElementDelimiterLength := 0;
  FSubelEmentSeperatorLength := 0;
end;

//--------------------------------------------------------------------------------------------------

constructor TEDIDelimiters.Create(const SD, ED, SS: string);
begin
  inherited Create;
  FSegmentDelimiter := SD;
  FElementDelimiter := ED;
  FSubElementSeperator := SS;
  FSegmentDelimiterLength := Length(SD);
  FElementDelimiterLength := Length(ED);
  FSubelementSeperatorLength := Length(SS);
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIDelimiters.SetED(const Delimiter: string);
begin
  FElementDelimiter := Delimiter;
  FElementDelimiterLength := Length(FElementDelimiter);
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIDelimiters.SetSD(const Delimiter: string);
begin
  FSegmentDelimiter := Delimiter;
  FSegmentDelimiterLength := Length(FSegmentDelimiter);
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIDelimiters.SetSS(const Delimiter: string);
begin
  FSubelementSeperator := Delimiter;
  FSubelementSeperatorLength := Length(FSubElementSeperator);
end;

//==================================================================================================
// TEDIDataObject
//==================================================================================================

constructor TEDIDataObject.Create(Parent: TEDIDataObject);
begin
  inherited Create;
  FState := ediCreated;
  FEDIDOT := ediUnknown;
  FData := '';
  FLength := 0;
  if Assigned(Parent) then
  begin
    FParent := Parent;
  end
  else
  begin
    FParent := nil;
  end;
  FDelimiters := nil;
end;

//--------------------------------------------------------------------------------------------------

destructor TEDIDataObject.Destroy;
begin
  if not Assigned(FParent) then
  begin
    if Assigned(FDelimiters) then
    begin
      FDelimiters.Free;
    end;
  end;
  FDelimiters := nil;
  inherited Destroy;
end;

//--------------------------------------------------------------------------------------------------

function TEDIDataObject.GetData: string;
begin
  Result := FData;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIDataObject.SetData(const Data: string);
begin
  FData := Data;
  FLength := Length(FData);
end;

//==================================================================================================
// TEDIElement
//==================================================================================================

constructor TEDIElement.Create(Parent: TEDIDataObject);
begin
  if Assigned(Parent) and (Parent is TEDISegment) then
  begin
    inherited Create(Parent);
  end
  else
  begin
    inherited Create(nil);
  end;
  FEDIDOT := ediElement;
end;

function TEDIElement.Assemble: string;
begin
  Result := FData;
  FState := ediAssembled;
end;

procedure TEDIElement.Dissassemble;
begin
  FState := ediDissassembled;
  //Override in decendant class
end;

//==================================================================================================
// TEDISegment
//==================================================================================================

function TEDISegment.AddElements(Count: Integer): Integer;
var
  I, J: Integer;
begin
  I := Length(FElements);
  Result := I; //Return position of 1st element
  //Resize
  SetLength(FElements, Length(FElements) + Count);
  //Add
  for J := I to High(FElements) do
  begin
    FElements[J]:= TEDIElement.Create(Self);
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDISegment.AddElement: Integer;
begin
  SetLength(FElements, Length(FElements) + 1);
  FElements[High(FElements)] := TEDIElement.Create(Self);
  Result := High(FElements); //Return position of element
end;

//--------------------------------------------------------------------------------------------------

function TEDISegment.AppendElement(Element: TEDIElement): Integer;
begin
  SetLength(FElements, Length(FElements) + 1);
  FElements[High(FElements)] := Element;
  Element.Parent := Self;
  Result := High(FElements); //Return position of element
end;

//--------------------------------------------------------------------------------------------------

function TEDISegment.AppendElements(ElementArray: TEDIElementArray): Integer;
var
  I, J, K: Integer;
begin
  I := 0;
  J := Length(FElements);
  Result := J; //Return position of 1st element
  //Resize
  SetLength(FElements, Length(FElements) + Length(ElementArray));
  //Append
  for K := J to High(ElementArray) do
  begin
    FElements[K] := ElementArray[I];
    FElements[K].Parent := Self;
    Inc(I);
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDISegment.Assemble: string;
var
  I: Integer;
begin
  FData := '';
  FLength := 0;
  Result := '';

  if not Assigned(FDelimiters) then //Attempt to assign the delimiters
  begin
    FDelimiters := InternalAssignDelimiters;
    if not Assigned(FDelimiters) then
    begin
      raise EJclEDIError.CreateResRec(@EDIError074);
    end;
  end;

  FData := FSegmentID;
  if Length(FElements) > 0 then
  begin
    for I := Low(FElements) to High(FElements) do
    begin
      if Assigned(FElements[I]) then
      begin
        FData := FData + FDelimiters.ED + FElements[I].Assemble;
      end
      else
      begin
        FData := FData + FDelimiters.ED;
      end;
    end;
  end;
  FData := FData + FDelimiters.SD;
  FLength := Length(FData);
  Result := FData; //Return assembled string

  DeleteElements;

  FState := ediAssembled;  
end;

//-------------------------------------------------------------------------------------------------

constructor TEDISegment.Create(Parent: TEDIDataObject; ElementCount: Integer);
begin
  if Assigned(Parent) and (Parent is TEDITransactionSet) then
  begin
    inherited Create(Parent);
  end
  else
  begin
    inherited Create(nil);
  end;
  FEDIDOT := ediSegment;
  SetLength(FElements, 0);
  AddElements(ElementCount);
end;

//--------------------------------------------------------------------------------------------------

constructor TEDISegment.Create(Parent: TEDIDataObject);
begin
  if Assigned(Parent) and (Parent is TEDITransactionSet) then
  begin
    inherited Create(Parent);
  end
  else
  begin
    inherited Create(nil);
  end;
  FEDIDOT := ediSegment;
  SetLength(FElements, 0);
end;

//--------------------------------------------------------------------------------------------------

procedure TEDISegment.DeleteElement(Index: Integer);
var
  I: Integer;
begin
  if (Length(FElements) > 0) and (Index >= Low(FElements)) and (Index <= High(FElements)) then
  begin
    //Delete
    FElements[Index].Free;
    FElements[Index] := nil;
    //Shift
    for I := Index + 1 to High(FElements) do
    begin
      FElements[I-1] := FElements[I];
    end;
    //Resize
    SetLength(FElements, High(FElements));
  end
  else
  begin
    raise EJclEDIError.CreateResRecFmt(@EDIError073, [IntToStr(Index)]);
  end;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDISegment.DeleteElement(Element: TEDIElement);
var
  I: Integer;
begin
  for I := Low(FElements) to High(FElements) do
  begin
    if FElements[I] = Element then
    begin
      DeleteElement(I);
    end;
  end;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDISegment.DeleteElements(Index, Count: Integer);
var
  I: Integer;
begin
  if (Length(FElements) > 0) and (Index >= Low(FElements)) and (Index <= High(FElements)) then
  begin
    //Delete
    for I := Index to (Index + Count) - 1 do
    begin
      if Assigned(FElements[I]) then
      begin
        FElements[I].Free;
        FElements[I] := nil;
      end;
    end;
    //Shift
    for I := (Index + Count) to High(FElements) do
    begin
      FElements[I-Count] := FElements[I];
      FElements[I] := nil;
    end;
    //Resize
    SetLength(FElements, Length(FElements) - Count);
  end
  else
  begin
    raise EJclEDIError.CreateResRecFmt(@EDIError072, [IntToStr(Index)]);
  end;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDISegment.DeleteElements;
var
  I: Integer;
begin
  for I := Low(FElements) to High(FElements) do
  begin
    if Assigned(FElements[I]) then
    begin
      //Delete
      FElements[I].Free;
      FElements[I] := nil;
    end;
  end;
  //Resize
  SetLength(FElements, 0);
end;

//--------------------------------------------------------------------------------------------------

destructor TEDISegment.Destroy;
begin
  DeleteElements;
  inherited Destroy;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDISegment.Dissassemble;
var
  I, StartPos, SearchResult: Integer;
begin
//Data Input Scenarios
//4.)  SegID*---*---~
//Composite Element Data Input Secnarios
//9.)  SegID*---*--->---~
  FSegmentID := '';
  DeleteElements;
  if not Assigned(FDelimiters) then //Attempt to assign the delimiters
  begin
    FDelimiters := InternalAssignDelimiters;
    if not Assigned(FDelimiters) then
    begin
      raise EJclEDIError.CreateResRec(@EDIError071);
    end;
  end;
  //Continue
  StartPos := 1;
  SearchResult := StrSearch(FDelimiters.ED, FData, StartPos);
  FSegmentID := Copy(FData, 1, SearchResult - 1);
  StartPos := SearchResult + 1;
  SearchResult := StrSearch(FDelimiters.ED, FData, StartPos);
  while SearchResult <> 0 do
  begin
    I := AddElement;
    if ((SearchResult - StartPos) > 0) then //data exists
    begin
      FElements[I].Data := Copy(FData, ((StartPos + FDelimiters.EDLen) - 1),
        (SearchResult - StartPos));
      FElements[I].Dissassemble;
    end;
    StartPos := SearchResult + 1;
    SearchResult := StrSearch(FDelimiters.ED, FData, StartPos);
  end;
  //Get last element before next segment
  SearchResult := StrSearch(FDelimiters.SD, FData, StartPos);
  if SearchResult <> 0 then
  begin
    if ((SearchResult - StartPos) > 0) then //data exists
    begin
      I := AddElement;
      FElements[I].Data := Copy(FData, ((StartPos + FDelimiters.EDLen) - 1),
        (SearchResult - StartPos));
      FElements[I].Dissassemble;
    end;
  end;
  FData := '';

  FState := ediDissassembled;
end;

//--------------------------------------------------------------------------------------------------

function TEDISegment.GetElement(Index: Integer): TEDIElement;
begin
  if (Length(FElements) > 0) then
    if (Index >= Low(FElements)) then
      if (Index <= High(FElements)) then
      begin
        if not Assigned(FElements[Index]) then
        begin
          raise EJclEDIError.CreateResRecFmt(@EDIError067, [IntToStr(Index)]);
        end;
        Result := FElements[Index];
      end
      else
        raise EJclEDIError.CreateResRecFmt(@EDIError068, [IntToStr(Index)])
    else
      raise EJclEDIError.CreateResRecFmt(@EDIError069, [IntToStr(Index)])
  else
    raise EJclEDIError.CreateResRecFmt(@EDIError070, [IntToStr(Index)]);
end;

//--------------------------------------------------------------------------------------------------

function TEDISegment.InsertElement(InsertIndex: Integer): Integer;
var
  I: Integer;
begin
  Result := InsertIndex;
  if (Length(FElements) > 0) and (InsertIndex >= Low(FElements)) and
    (InsertIndex <= High(FElements)) then
  begin
    //Resize
    SetLength(FElements, Length(FElements) + 1);
    //Shift
    for I := High(FElements) downto InsertIndex + 1 do
    begin
      FElements[I] := FElements[I-1];
    end;
    //Insert
    FElements[InsertIndex] := nil;
    FElements[InsertIndex] := TEDIElement.Create(Self);
  end
  else
  begin
    Result := AddElement;
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDISegment.InsertElement(InsertIndex: Integer; Element: TEDIElement): Integer;
var
  I: Integer;
begin
  Result := InsertIndex;
  if (Length(FElements) > 0) and (InsertIndex >= Low(FElements)) and
    (InsertIndex <= High(FElements)) then
  begin
    //Resize
    SetLength(FElements, Length(FElements) + 1);
    //Shift
    for I := High(FElements) downto InsertIndex + 1 do
    begin
      FElements[I] := FElements[I-1];
    end;
    //Insert
    FElements[InsertIndex] := nil;
    FElements[InsertIndex] := Element;
    FElements[InsertIndex].Parent := Self;
  end
  else
  begin
    Result := AppendElement(Element);
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDISegment.InsertElements(InsertIndex: Integer; ElementArray: TEDIElementArray): Integer;
var
  I, J, K: Integer;
begin
  Result := InsertIndex;
  I := Length(ElementArray);
  if (Length(FElements) > 0) and (InsertIndex >= Low(FElements)) and
    (InsertIndex <= High(FElements)) then
  begin
    //Resize
    SetLength(FElements, Length(FElements) + I);
    //Shift
    for J := High(FElements) downto InsertIndex + I do
    begin
      FElements[J] := FElements[J-I];
      FElements[J-I] := nil;
    end;
    //Insert
    K := 0;
    for J := InsertIndex to (InsertIndex + I) - 1 do
    begin
      FElements[J] := ElementArray[K];
      FElements[J].Parent := Self;
      Inc(K);
    end;
  end
  else
  begin
    Result := AppendElements(ElementArray);
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDISegment.InsertElements(InsertIndex, Count: Integer): Integer;
var
  I: Integer;
begin
  Result := InsertIndex;
  if (Length(FElements) > 0) and (InsertIndex >= Low(FElements)) and
    (InsertIndex <= High(FElements)) then
  begin
    //Resize
    SetLength(FElements, Length(FElements) + Count);
    //Shift
    for I := High(FElements) downto InsertIndex + Count do
    begin
      FElements[I] := FElements[I-Count];
      FElements[I-Count] := nil;
    end;
    //Insert
    for I := InsertIndex to (InsertIndex + Count) - 1 do
    begin
      FElements[I] := TEDIElement.Create(Self);
    end;
  end
  else
  begin
    Result := AddElements(Count);
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDISegment.InternalAssignDelimiters: TEDIDelimiters;
begin
  Result := nil;
  if not Assigned(FDelimiters) then //Attempt to assign the delimiters
  begin
    //Get the delimiters from the transaction set
    if Assigned(Parent) and (Parent is TEDITransactionSet) then
    begin
      if Assigned(Parent.Delimiters) then
      begin
        Result := Parent.Delimiters;
        Exit;
      end;
      //Get the delimiters from the functional group
      if Assigned(Parent.Parent) and (Parent.Parent is TEDIFunctionalGroup) then
      begin
        if Assigned(Parent.Parent.Delimiters) then
        begin
          Result := Parent.Parent.Delimiters;
          Exit;
        end;
        //Get the delimiters from the interchange control header
        if Assigned(Parent.Parent.Parent) and (Parent.Parent.Parent is TEDIInterchangeControl) then
        begin
          if Assigned(Parent.Parent.Parent.Delimiters) then
          begin
            Result := Parent.Parent.Parent.Delimiters;
          end;
        end;
      end;
    end;
  end;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDISegment.SetElement(Index: Integer; Element: TEDIElement);
begin
  if (Length(FElements) > 0) then
    if (Index >= Low(FElements)) then
      if (Index <= High(FElements)) then
      begin
        if Assigned(FElements[Index]) then
        begin
          FElements[Index].Free;
          FElements[Index] := nil;
        end;
        FElements[Index] := Element;
      end
      else
        raise EJclEDIError.CreateResRecFmt(@EDIError064, [IntToStr(Index)])
    else
      raise EJclEDIError.CreateResRecFmt(@EDIError065, [IntToStr(Index)])
  else
    raise EJclEDIError.CreateResRecFmt(@EDIError066, [IntToStr(Index)]);
end;

//==================================================================================================
// TEDITransactionSetSegment
//==================================================================================================

constructor TEDITransactionSetSegment.Create(Parent: TEDIDataObject);
begin
  inherited;
  if Assigned(Parent) and (Parent is TEDITransactionSet) then
  begin
    FParent := Parent;
  end;
end;

//--------------------------------------------------------------------------------------------------

constructor TEDITransactionSetSegment.Create(Parent: TEDIDataObject; ElementCount: Integer);
begin
  inherited;
  if Assigned(Parent) and (Parent is TEDITransactionSet) then
  begin
    FParent := Parent;
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDITransactionSetSegment.InternalAssignDelimiters: TEDIDelimiters;
begin
  Result := inherited InternalAssignDelimiters;
end;

//==================================================================================================
// TEDIFunctionalGroupSegment
//==================================================================================================

constructor TEDIFunctionalGroupSegment.Create(Parent: TEDIDataObject);
begin
  inherited;
  if Assigned(Parent) and (Parent is TEDIFunctionalGroup) then
  begin
    FParent := Parent;
  end;
end;

//--------------------------------------------------------------------------------------------------

constructor TEDIFunctionalGroupSegment.Create(Parent: TEDIDataObject; ElementCount: Integer);
begin
  inherited;
  if Assigned(Parent) and (Parent is TEDIFunctionalGroup) then
  begin
    FParent := Parent;
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDIFunctionalGroupSegment.InternalAssignDelimiters: TEDIDelimiters;
begin
  Result := nil;
  //Attempt to assign the delimiters
  if not Assigned(FDelimiters) then
  begin
    //Get the delimiters from the functional group
    if Assigned(Parent) and (Parent is TEDIFunctionalGroup) then
    begin
      if Assigned(Parent.Delimiters) then
      begin
        Result := Parent.Delimiters;
        Exit;
      end;
      //Get the delimiters from the interchange control
      if Assigned(Parent.Parent) and (Parent.Parent is TEDIInterchangeControl) then
      begin
        if Assigned(Parent.Parent.Delimiters) then
        begin
          Result := Parent.Parent.Delimiters;
        end;
      end;
    end;
  end;
end;

//==================================================================================================
// TEDIInterchangeControlSegment
//==================================================================================================

constructor TEDIInterchangeControlSegment.Create(Parent: TEDIDataObject);
begin
  inherited;
  if Assigned(Parent) and (Parent is TEDIInterchangeControl) then
  begin
    FParent := Parent;
  end;
end;

//--------------------------------------------------------------------------------------------------

constructor TEDIInterchangeControlSegment.Create(Parent: TEDIDataObject; ElementCount: Integer);
begin
  inherited;
  if Assigned(Parent) and (Parent is TEDIInterchangeControl) then
  begin
    FParent := Parent;
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDIInterchangeControlSegment.InternalAssignDelimiters: TEDIDelimiters;
begin
  Result := nil;
  //Attempt to assign the delimiters
  if not Assigned(FDelimiters) then
  begin
    //Get the delimiters from the interchange control
    if Assigned(Parent) and (Parent is TEDIInterchangeControl) then
    begin
      if Assigned(Parent.Delimiters) then
      begin
        Result := Parent.Delimiters;
      end;
    end;
  end;
end;

//==================================================================================================
// TEDITransactionSet
//==================================================================================================

function TEDITransactionSet.AddSegment: Integer;
begin
  SetLength(FSegments, Length(FSegments) + 1);
  if Assigned(Parent) and (Parent is TEDIFunctionalGroup) then
  begin
    if Assigned(Parent.Parent) and (Parent.Parent is TEDIInterchangeControl) then
    begin
      if TEDIInterchangeControl(Parent.Parent).FEDIDUT = ediUseAsSpec then
      begin
        FSegments[High(FSegments)] := TEDISegmentSpec.Create(Self);
      end
      else
      begin
        FSegments[High(FSegments)] := TEDISegment.Create(Self);
      end;
    end
    else
    begin
      FSegments[High(FSegments)] := TEDISegment.Create(Self);
    end;
  end
  else
  begin
    FSegments[High(FSegments)] := TEDISegment.Create(Self);
  end;
  Result := High(FSegments);
end;

//--------------------------------------------------------------------------------------------------

function TEDITransactionSet.AddSegments(Count: Integer): Integer;
var
  I, J: Integer;
begin
  I := Length(FSegments);
  Result := I;
  //Resize
  SetLength(FSegments, Length(FSegments) + Count);
  //Add
  for J := I to High(FSegments) do
  begin
    if Assigned(Parent) and (Parent is TEDIFunctionalGroup) then
    begin
      if Assigned(Parent.Parent) and (Parent.Parent is TEDIInterchangeControl) then
      begin
        if TEDIInterchangeControl(Parent.Parent).FEDIDUT = ediUseAsSpec then
        begin
          FSegments[J]:= TEDISegmentSpec.Create(Self);
        end
        else
        begin
          FSegments[J]:= TEDISegment.Create(Self);
        end;
      end
      else
      begin
        FSegments[J]:= TEDISegment.Create(Self);
      end;
    end
    else
    begin
      FSegments[J]:= TEDISegment.Create(Self);
    end;
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDITransactionSet.AppendSegment(Segment: TEDISegment): Integer;
begin
  SetLength(FSegments, Length(FSegments) + 1);
  FSegments[High(FSegments)] := Segment;
  Segment.Parent := Self;
  Result := High(FSegments);
end;

//--------------------------------------------------------------------------------------------------

function TEDITransactionSet.AppendSegments(SegmentArray: TEDISegmentArray): Integer;
var
  J, K, I: Integer;
begin
  I := 0;
  J := Length(FSegments);
  Result := J;
  //Resize
  SetLength(FSegments, Length(FSegments) + Length(SegmentArray));
  //Append
  for K := J to High(SegmentArray) do
  begin
    FSegments[K] := SegmentArray[I];
    FSegments[K].Parent := Self;
    Inc(I);
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDITransactionSet.Assemble: string;
var
  I: Integer;
begin
  FData := '';
  FLength := 0;
  Result := '';
  if not Assigned(FDelimiters) then //Attempt to assign the delimiters
  begin
    FDelimiters := InternalAssignDelimiters;
    if not Assigned(FDelimiters) then
    begin
      raise EJclEDIError.CreateResRec(@EDIError063);
    end;
  end;

  FData := FSTSegment.Assemble;
  FSTSegment.Data := '';

  if Length(FSegments) > 0 then
  begin
    for I := Low(FSegments) to High(FSegments) do
    begin
      if Assigned(FSegments[I]) then
      begin
        FData := FData + FSegments[I].Assemble;
      end;
    end;
  end;

  DeleteSegments;

  FData := FData + FSESegment.Assemble;
  FSESegment.Data := '';

  FLength := Length(FData);
  Result := FData;

  FState := ediAssembled;
end;

//--------------------------------------------------------------------------------------------------

constructor TEDITransactionSet.Create(Parent: TEDIDataObject; SegmentCount: Integer);
begin
  if Assigned(Parent) and (Parent is TEDIFunctionalGroup) then
  begin
    inherited Create(Parent);
  end
  else
  begin
    inherited Create(nil);
  end;
  FEDIDOT := ediTransactionSet;
  if Assigned(Parent) and (Parent is TEDIFunctionalGroup) then
  begin
    if Assigned(Parent.Parent) and (Parent.Parent is TEDIInterchangeControl) then
    begin
      if TEDIInterchangeControl(Parent.Parent).FEDIDUT = ediUseAsSpec then
      begin
        FSTSegment := TEDITransactionSetSegment(TEDITransactionSetSegmentSTSpec.Create(Self));
        FSESegment := TEDITransactionSetSegment(TEDITransactionSetSegmentSpec.Create(Self));
      end
      else
      begin
        FSTSegment := TEDITransactionSetSegment.Create(Self);
        FSESegment := TEDITransactionSetSegment.Create(Self);
      end;
    end
    else
    begin
      FSTSegment := TEDITransactionSetSegment.Create(Self);
      FSESegment := TEDITransactionSetSegment.Create(Self);
    end;
  end
  else
  begin
    FSTSegment := TEDITransactionSetSegment.Create(Self);
    FSESegment := TEDITransactionSetSegment.Create(Self);
  end;
  SetLength(FSegments, 0);
  AddSegments(SegmentCount);
end;

//--------------------------------------------------------------------------------------------------

constructor TEDITransactionSet.Create(Parent: TEDIDataObject);
begin
  if Assigned(Parent) and (Parent is TEDIFunctionalGroup) then
  begin
    inherited Create(Parent);
  end
  else
  begin
    inherited Create(nil);
  end;
  FEDIDOT := ediTransactionSet;
  if Assigned(Parent) and (Parent is TEDIFunctionalGroup) then
  begin
    if Assigned(Parent.Parent) and (Parent.Parent is TEDIInterchangeControl) then
    begin
      if TEDIInterchangeControl(Parent.Parent).FEDIDUT = ediUseAsSpec then
      begin
        FSTSegment := TEDITransactionSetSegment(TEDITransactionSetSegmentSTSpec.Create(Self));
        FSESegment := TEDITransactionSetSegment(TEDITransactionSetSegmentSpec.Create(Self));
      end
      else
      begin
        FSTSegment := TEDITransactionSetSegment.Create(Self);
        FSESegment := TEDITransactionSetSegment.Create(Self);
      end;
    end
    else
    begin
      FSTSegment := TEDITransactionSetSegment.Create(Self);
      FSESegment := TEDITransactionSetSegment.Create(Self);
    end;
  end
  else
  begin
    FSTSegment := TEDITransactionSetSegment.Create(Self);
    FSESegment := TEDITransactionSetSegment.Create(Self);
  end;
  SetLength(FSegments, 0);
end;

//--------------------------------------------------------------------------------------------------

procedure TEDITransactionSet.DeleteSegment(Index: Integer);
var
  I: Integer;
begin
  if (Length(FSegments) > 0) and (Index >= Low(FSegments)) and (Index <= High(FSegments)) then
  begin
    //Delete
    FSegments[Index].Free;
    FSegments[Index] := nil;
    //Shift
    for I := Index + 1 to High(FSegments) do
    begin
      FSegments[I-1] := FSegments[I];
    end;
    //Resize
    SetLength(FSegments, High(FSegments));
  end
  else
  begin
    raise EJclEDIError.CreateResRec(@EDIError062);
  end;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDITransactionSet.DeleteSegment(Segment: TEDISegment);
var
  I: Integer;
begin
  for I := Low(FSegments) to High(FSegments) do
  begin
    if FSegments[I] = Segment then
    begin
      DeleteSegment(I);
    end;
  end;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDITransactionSet.DeleteSegments;
var
  I: Integer;
begin
  for I := Low(FSegments) to High(FSegments) do
  begin
    if Assigned(FSegments[I]) then
    begin
      //Delete
      FSegments[I].Free;
      FSegments[I] := nil;
    end;
  end;
  //Resize
  SetLength(FSegments, 0);
end;

//--------------------------------------------------------------------------------------------------

procedure TEDITransactionSet.DeleteSegments(Index, Count: Integer);
var
  I: Integer;
begin
  if (Length(FSegments) > 0) and (Index >= Low(FSegments)) and (Index <= High(FSegments)) then
  begin
    //Delete
    for I := Index to (Index + Count) - 1 do
    begin
      if Assigned(FSegments[I]) then
      begin
        FSegments[I].Free;
        FSegments[I] := nil;
      end;
    end;
    //Shift
    for I := (Index + Count) to High(FSegments) do
    begin
      FSegments[I-Count] := FSegments[I];
      FSegments[I] := nil;
    end;
    //Resize
    SetLength(FSegments, Length(FSegments) - Count);
  end
  else
  begin
    raise EJclEDIError.CreateResRecFmt(@EDIError061, [IntToStr(Index)]);
  end;
end;

//--------------------------------------------------------------------------------------------------

destructor TEDITransactionSet.Destroy;
begin
  DeleteSegments;
  FSESegment.Free;
  FSTSegment.Free;
  inherited Destroy;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDITransactionSet.Dissassemble;
var
  I, StartPos, SearchResult: Integer;
  S, S2: string;
begin
  FSTSegment.Data := '';
  FSTSegment.DeleteElements;
  FSESegment.Data := '';
  FSESegment.DeleteElements;
  DeleteSegments;
  //Check delimiter assignment
  if not Assigned(FDelimiters) then
  begin
    FDelimiters := InternalAssignDelimiters;
    if not Assigned(FDelimiters) then
    begin
      raise EJclEDIError.CreateResRec(@EDIError060);
    end;
  end;
  //Find the first segment
  StartPos := 1;
  SearchResult := StrSearch(FDelimiters.SD, FData, StartPos);
  while SearchResult <> 0 do
  begin
    S := Copy(FData, ((StartPos + FDelimiters.SDLen) - 1), Length(TSHSegmentId));
    S2 := Copy(FData, ((StartPos + FDelimiters.SDLen) - 1), Length(TSTSegmentId));
    if (S <> TSHSegmentId) and (S2 <> TSTSegmentId) then
    begin
      I := AddSegment;
      if ((SearchResult - StartPos) > 0) then //data exists
      begin
        FSegments[I].Data := Copy(FData, ((StartPos + FDelimiters.SDLen) - 1),
          ((SearchResult - StartPos) + FDelimiters.SDLen));
        FSegments[I].Dissassemble;
      end;
    end
    else if S = TSHSegmentId then
    begin
      if ((SearchResult - StartPos) > 0) then //data exists
      begin
        FSTSegment.Data := Copy(FData, ((StartPos + FDelimiters.SDLen) - 1),
          ((SearchResult - StartPos) + FDelimiters.SDLen));
        FSTSegment.Dissassemble;
      end;
    end
    else if S2 = TSTSegmentId then
    begin
      if ((SearchResult - StartPos) > 0) then //data exists
      begin
        FSESegment.Data := Copy(FData, ((StartPos + FDelimiters.SDLen) - 1),
          ((SearchResult - StartPos) + FDelimiters.SDLen));
        FSESegment.Dissassemble;
      end;
    end;
    StartPos := SearchResult + FDelimiters.SDLen;
    SearchResult := StrSearch(FDelimiters.SD, FData, StartPos);
  end;
  FData := '';

  FState := ediDissassembled;
end;

//--------------------------------------------------------------------------------------------------

function TEDITransactionSet.GetSegment(Index: Integer): TEDISegment;
begin
  if (Length(FSegments) > 0) then
    if (Index >= Low(FSegments)) then
      if (Index <= High(FSegments)) then
      begin
        if not Assigned(FSegments[Index]) then
        begin
          raise EJclEDIError.CreateResRecFmt(@EDIError056, [IntToStr(Index)]);
        end;
        Result := FSegments[Index];
      end
      else
        raise EJclEDIError.CreateResRecFmt(@EDIError057, [IntToStr(Index)])
    else
      raise EJclEDIError.CreateResRecFmt(@EDIError058, [IntToStr(Index)])
  else
    raise EJclEDIError.CreateResRecFmt(@EDIError059, [IntToStr(Index)]);
end;

//--------------------------------------------------------------------------------------------------

function TEDITransactionSet.InsertSegment(InsertIndex: Integer): Integer;
var
  I: Integer;
begin
  Result := InsertIndex;
  if (Length(FSegments) > 0) and (InsertIndex >= Low(FSegments)) and
    (InsertIndex <= High(FSegments)) then
  begin
    //Resize
    SetLength(FSegments, Length(FSegments) + 1);
    //Shift
    for I := High(FSegments) downto InsertIndex + 1 do
    begin
      FSegments[I] := FSegments[I-1];
    end;
    //Insert
    FSegments[InsertIndex] := nil;
    if Assigned(Parent) and (Parent is TEDIFunctionalGroup) then
    begin
      if Assigned(Parent.Parent) and (Parent.Parent is TEDIInterchangeControl) then
      begin
        if TEDIInterchangeControl(Parent.Parent).FEDIDUT = ediUseAsSpec then
        begin
          FSegments[InsertIndex] := TEDISegmentSpec.Create(Self);
        end
        else
        begin
          FSegments[InsertIndex] := TEDISegment.Create(Self);
        end;
      end
      else
      begin
        FSegments[InsertIndex] := TEDISegment.Create(Self);
      end;
    end
    else
    begin
      FSegments[InsertIndex] := TEDISegment.Create(Self);
    end;
  end
  else
  begin
    Result := AddSegment;
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDITransactionSet.InsertSegment(InsertIndex: Integer; Segment: TEDISegment): Integer;
var
  I: Integer;
begin
  Result := InsertIndex;
  if (Length(FSegments) > 0) and (InsertIndex >= Low(FSegments)) and
    (InsertIndex <= High(FSegments)) then
  begin
    //Resize
    SetLength(FSegments, Length(FSegments) + 1);
    //Shift
    for I := High(FSegments) downto InsertIndex + 1 do
    begin
      FSegments[I] := FSegments[I-1];
    end;
    //Insert
    FSegments[InsertIndex] := nil;
    FSegments[InsertIndex] := Segment;
    FSegments[InsertIndex].Parent := Self;
  end
  else
  begin
    Result := AppendSegment(Segment);
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDITransactionSet.InsertSegments(InsertIndex, Count: Integer): Integer;
var
  I: Integer;
begin
  Result := InsertIndex;
  if (Length(FSegments) > 0) and (InsertIndex >= Low(FSegments)) and
    (InsertIndex <= High(FSegments)) then
  begin
    //Resize
    SetLength(FSegments, Length(FSegments) + Count);
    //Shift
    for I := High(FSegments) downto InsertIndex + Count do
    begin
      FSegments[I] := FSegments[I-Count];
      FSegments[I-Count] := nil;
    end;
    //Insert
    for I := InsertIndex to (InsertIndex + Count) - 1 do
    begin
      if Assigned(Parent) and (Parent is TEDIFunctionalGroup) then
      begin
        if Assigned(Parent.Parent) and (Parent.Parent is TEDIInterchangeControl) then
        begin
          if TEDIInterchangeControl(Parent.Parent).FEDIDUT = ediUseAsSpec then
          begin
            FSegments[I] := TEDISegmentSpec.Create(Self);
          end
          else
          begin
            FSegments[I] := TEDISegment.Create(Self);
          end;
        end
        else
        begin
          FSegments[I] := TEDISegment.Create(Self);
        end;
      end
      else
      begin
        FSegments[I] := TEDISegment.Create(Self);
      end;
    end;
  end
  else
  begin
    Result := AddSegments(Count);
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDITransactionSet.InsertSegments(InsertIndex: Integer;
  SegmentArray: TEDISegmentArray): Integer;
var
  I, J, K: Integer;
begin
  Result := InsertIndex;
  I := Length(SegmentArray);
  if (Length(FSegments) > 0) and (InsertIndex >= Low(FSegments)) and
    (InsertIndex <= High(FSegments)) then
  begin
    //Resize
    SetLength(FSegments, Length(FSegments) + I);
    //Shift
    for J := High(FSegments) downto InsertIndex + I do
    begin
      FSegments[J] := FSegments[J-I];
      FSegments[J-I] := nil;
    end;
    //Insert
    K := 0;
    for J := InsertIndex to (InsertIndex + I) - 1 do
    begin
      FSegments[J] := SegmentArray[K];
      FSegments[J].Parent := Self;
      Inc(K);
    end;
  end
  else
  begin
    Result := AppendSegments(SegmentArray);
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDITransactionSet.InternalAssignDelimiters: TEDIDelimiters;
begin
  Result := nil;
  if FDelimiters = nil then //Attempt to assign the delimiters
  begin
    if Assigned(Parent) and (Parent is TEDIFunctionalGroup) then
    begin
      if Assigned(Parent.Delimiters) then
      begin
        Result := Parent.Delimiters;
        Exit;
      end;
      if Assigned(Parent.Parent) and (Parent.Parent is TEDIInterchangeControl) then
      begin
        if Assigned(Parent.Parent.Delimiters) then
        begin
          Result := Parent.Parent.Delimiters;
        end;
      end;
    end;
  end;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDITransactionSet.SetSegment(Index: Integer; Segment: TEDISegment);
begin
  if (Length(FSegments) > 0) then
    if (Index >= Low(FSegments)) then
      if (Index <= High(FSegments)) then
      begin
        if Assigned(FSegments[Index]) then
        begin
          FSegments[Index].Free;
          FSegments[Index] := nil;
        end;
        FSegments[Index] := Segment;
      end
      else
        raise EJclEDIError.CreateResRecFmt(@EDIError053, [IntToStr(Index)])
    else
      raise EJclEDIError.CreateResRecFmt(@EDIError054, [IntToStr(Index)])
  else
    raise EJclEDIError.CreateResRecFmt(@EDIError055, [IntToStr(Index)]);
end;

//==================================================================================================
// TEDIFunctionalGroup
//==================================================================================================

function TEDIFunctionalGroup.AddTransactionSet: Integer;
begin
  SetLength(FTransactionSets, Length(FTransactionSets) + 1);
  if Assigned(Parent) and (Parent is TEDIInterchangeControl) then
  begin
    if TEDIInterchangeControl(Parent).FEDIDUT = ediUseAsSpec then
    begin
      FTransactionSets[High(FTransactionSets)] := TEDITransactionSetSpec.Create(Self);
    end
    else
    begin
      FTransactionSets[High(FTransactionSets)] := TEDITransactionSet.Create(Self);
    end;
  end
  else
  begin
    FTransactionSets[High(FTransactionSets)] := TEDITransactionSet.Create(Self);
  end;
  Result := High(FTransactionSets);
end;

//--------------------------------------------------------------------------------------------------

function TEDIFunctionalGroup.AddTransactionSets(Count: Integer): Integer;
var
  I, J: Integer;
begin
  I := Length(FTransactionSets); //Previous Count
  Result := I;
  //Resize
  SetLength(FTransactionSets, Length(FTransactionSets) + Count);
  //Add
  for J := I to High(FTransactionSets) do
  begin
    if Assigned(Parent) and (Parent is TEDIInterchangeControl) then
    begin
      if TEDIInterchangeControl(Parent).FEDIDUT = ediUseAsSpec then
      begin
        FTransactionSets[J] := TEDITransactionSetSpec.Create(Self);
      end
      else
      begin
        FTransactionSets[J] := TEDITransactionSet.Create(Self);
      end;
    end
    else
    begin
      FTransactionSets[J] := TEDITransactionSet.Create(Self);
    end;
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDIFunctionalGroup.AppendTransactionSet(TransactionSet: TEDITransactionSet): Integer;
begin
  SetLength(FTransactionSets, Length(FTransactionSets) + 1);
  FTransactionSets[High(FTransactionSets)] := TransactionSet;
  TransactionSet.Parent := Self;
  Result := High(FTransactionSets);
end;

//--------------------------------------------------------------------------------------------------

function TEDIFunctionalGroup.AppendTransactionSets(
  TransactionSetArray: TEDITransactionSetArray): Integer;
var
  I, J, K: Integer;
begin
  I := 0;
  J := Length(FTransactionSets);
  Result := J;
  //Resize
  SetLength(FTransactionSets, Length(FTransactionSets) + Length(TransactionSetArray));
  //Append
  for K := J to High(TransactionSetArray) do
  begin
    FTransactionSets[K] := TransactionSetArray[I];
    FTransactionSets[K].Parent := Self;
    Inc(I);
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDIFunctionalGroup.Assemble: string;
var
  I: Integer;
begin
  FData := '';
  FLength := 0;
  Result := '';
  if not Assigned(FDelimiters) then //Attempt to assign the delimiters
  begin
    FDelimiters := InternalAssignDelimiters;
    if not Assigned(FDelimiters) then
    begin
      raise EJclEDIError.CreateResRec(@EDIError052);
    end;
  end;
  FData := FGSSegment.Assemble;
  FGSSegment.Data := '';

  if (Length(FTransactionSets) > 0) then
  begin
    for I := Low(FTransactionSets) to High(FTransactionSets) do
    begin
      if Assigned(FTransactionSets[I]) then
      begin
        FData := FData + FTransactionSets[I].Assemble;
      end;
    end;
  end;

  DeleteTransactionSets;

  FData := FData + FGESegment.Assemble;
  FGESegment.Data := '';

  FLength := Length(FData);
  Result := FData;

  FState := ediAssembled;
end;

//--------------------------------------------------------------------------------------------------

constructor TEDIFunctionalGroup.Create(Parent: TEDIDataObject);
begin
  if Assigned(Parent) and (Parent is TEDIInterchangeControl) then
  begin
    inherited Create(Parent);
  end
  else
  begin
    inherited Create(nil);
  end;
  FEDIDOT := ediFunctionalGroup;
  if Assigned(Parent) and (Parent is TEDIInterchangeControl) then
  begin
    if TEDIInterchangeControl(Parent).FEDIDUT = ediUseAsSpec then
    begin
      FGSSegment := TEDIFunctionalGroupSegment(TEDIFunctionalGroupSegmentGSSpec.Create(Self));
      FGESegment := TEDIFunctionalGroupSegment(TEDIFunctionalGroupSegmentSpec.Create(Self));
    end
    else
    begin
      FGSSegment := TEDIFunctionalGroupSegment.Create(Self);
      FGESegment := TEDIFunctionalGroupSegment.Create(Self);
    end;
  end
  else
  begin
    FGSSegment := TEDIFunctionalGroupSegment.Create(Self);
    FGESegment := TEDIFunctionalGroupSegment.Create(Self);
  end;
  SetLength(FTransactionSets, 0);
end;

//--------------------------------------------------------------------------------------------------

constructor TEDIFunctionalGroup.Create(Parent: TEDIDataObject; TransactionSetCount: Integer);
begin
  if Assigned(Parent) and (Parent is TEDIInterchangeControl) then
  begin
    inherited Create(Parent);
  end
  else
  begin
    inherited Create(nil);
  end;
  FEDIDOT := ediFunctionalGroup;
  if Assigned(Parent) and (Parent is TEDIInterchangeControl) then
  begin
    if TEDIInterchangeControl(Parent).FEDIDUT = ediUseAsSpec then
    begin
      FGSSegment := TEDIFunctionalGroupSegment(TEDIFunctionalGroupSegmentGSSpec.Create(Self));
      FGESegment := TEDIFunctionalGroupSegment(TEDIFunctionalGroupSegmentSpec.Create(Self));
    end
    else
    begin
      FGSSegment := TEDIFunctionalGroupSegment.Create(Self);
      FGESegment := TEDIFunctionalGroupSegment.Create(Self);
    end;
  end
  else
  begin
    FGSSegment := TEDIFunctionalGroupSegment.Create(Self);
    FGESegment := TEDIFunctionalGroupSegment.Create(Self);
  end;
  SetLength(FTransactionSets, 0);
  AddTransactionSets(TransactionSetCount);
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIFunctionalGroup.DeleteTransactionSet(Index: Integer);
var
  I: Integer;
begin
  if (Length(FTransactionSets) > 0) and (Index >= Low(FTransactionSets)) and
    (Index <= High(FTransactionSets)) then
  begin
    //Delete
    FTransactionSets[Index].Free;
    FTransactionSets[Index] := nil;
    //Shift
    for I := Index + 1 to High(FTransactionSets) do
    begin
      FTransactionSets[I-1] := FTransactionSets[I];
    end;
    //Resize
    SetLength(FTransactionSets, High(FTransactionSets));
  end
  else
  begin
    raise EJclEDIError.CreateResRecFmt(@EDIError051, [IntToStr(Index)]);
  end;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIFunctionalGroup.DeleteTransactionSet(TransactionSet: TEDITransactionSet);
var
  I: Integer;
begin
  for I := Low(FTransactionSets) to High(FTransactionSets) do
  begin
    if FTransactionSets[I] = TransactionSet then
    begin
      DeleteTransactionSet(I);
    end;
  end;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIFunctionalGroup.DeleteTransactionSets;
var
  I: Integer;
begin
  for I := Low(FTransactionSets) to High(FTransactionSets) do
  begin
    if Assigned(FTransactionSets[I]) then
    begin
      //Delete
      FTransactionSets[I].Free;
      FTransactionSets[I] := nil;
    end;
  end;
  //Resize
  SetLength(FTransactionSets, 0);
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIFunctionalGroup.DeleteTransactionSets(Index, Count: Integer);
var
  I: Integer;
begin
  if (Length(FTransactionSets) > 0) and (Index >= Low(FTransactionSets)) and
    (Index <= High(FTransactionSets)) then
  begin
    //Delete
    for I := Index to (Index + Count) - 1 do
    begin
      if Assigned(FTransactionSets[I]) then
      begin
        FTransactionSets[I].Free;
        FTransactionSets[I] := nil;
      end;
    end;
    //Shift
    for I := (Index + Count) to High(FTransactionSets) do
    begin
      FTransactionSets[I-Count] := FTransactionSets[I];
      FTransactionSets[I] := nil;
    end;
    //Resize
    SetLength(FTransactionSets, Length(FTransactionSets) - Count);
  end
  else
  begin
    raise EJclEDIError.CreateResRecFmt(@EDIError050, [IntToStr(Index)]);
  end;
end;

//--------------------------------------------------------------------------------------------------

destructor TEDIFunctionalGroup.Destroy;
begin
  FGSSegment.Free;
  FGESegment.Free;
  DeleteTransactionSets;
  inherited Destroy;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIFunctionalGroup.Dissassemble;
var
  I, StartPos, SearchResult: Integer;
begin
  FGSSegment.Data := '';
  FGSSegment.DeleteElements;
  FGESegment.Data := '';
  FGESegment.DeleteElements;
  DeleteTransactionSets;
  //Check delimiter assignment
  if not Assigned(FDelimiters) then
  begin
    FDelimiters := InternalAssignDelimiters;
    if not Assigned(FDelimiters) then
    begin
      raise EJclEDIError.CreateResRec(@EDIError042);
    end;
  end;
  //Find Functional Group Header Segment
  StartPos := 1;
  //Search for Functional Group Header
  if FGHSegmentId + FDelimiters.ED = Copy(FData, 1, Length(FGHSegmentId + FDelimiters.ED)) then
  begin
    //Search for Functional Group Header Segment Terminator
    SearchResult := StrSearch(FDelimiters.SD, FData, 1);
    if (SearchResult - StartPos) > 0 then //data exists
    begin
      FGSSegment.Data := Copy(FData, 1, (SearchResult + FDelimiters.SDLen) - 1);
      FGSSegment.Dissassemble;
    end
    else
    begin
      raise EJclEDIError.CreateResRec(@EDIError043);
    end;
  end
  else
  begin
    raise EJclEDIError.CreateResRec(@EDIError044);
  end;
  //Search for Transaction Set Header
  SearchResult := StrSearch(FDelimiters.SD + TSHSegmentId + FDelimiters.ED, FData, StartPos);
  if SearchResult <= 0 then
  begin
    raise EJclEDIError.CreateResRec(@EDIError045);
  end;
  //Set next start position
  StartPos := SearchResult + FDelimiters.SDLen; //Move past the delimiter
  //Continue
  while SearchResult <> 0 do
  begin
    //Search for Transaction Set Trailer
    SearchResult := StrSearch(FDelimiters.SD + TSTSegmentId + FDelimiters.ED, FData, StartPos);
    if SearchResult <> 0 then
    begin
      //Set the next start position
      SearchResult := SearchResult + FDelimiters.SDLen; //Move past the delimiter
      //Search for the end of Transaction Set Trailer
      SearchResult := StrSearch(FDelimiters.SD, FData, SearchResult);
      if SearchResult <> 0 then
      begin
        I := AddTransactionSet;
        FTransactionSets[I].Data :=
          Copy(FData, StartPos, ((SearchResult - StartPos) + FDelimiters.SDLen));
        FTransactionSets[I].Dissassemble;
      end
      else
      begin
        raise EJclEDIError.CreateResRec(@EDIError046);
      end;
    end
    else
    begin
      raise EJclEDIError.CreateResRec(@EDIError047);
    end;
    //Set the next start position
    StartPos := SearchResult + FDelimiters.SDLen; //Move past the delimiter
    //
    //Verify the next record is a Transaction Set Header
    if (TSHSegmentId + FDelimiters.ED) <>
      Copy(FData, StartPos, (Length(TSHSegmentId) + FDelimiters.EDLen)) then
    begin
      Break;
    end;
  end;
  //Set the next start position
  StartPos := SearchResult + FDelimiters.SDLen; //Move past the delimiter
  //Find Functional Group Trailer Segment
  if (FGTSegmentId + FDelimiters.ED) =
    Copy(FData, StartPos, Length(FGTSegmentId + FDelimiters.ED)) then
  begin
    //Find Functional Group Trailer Segment Terminator
    SearchResult := StrSearch(FDelimiters.SD, FData, StartPos + FDelimiters.SDLen);
    if (SearchResult - StartPos) > 0 then //data exists
    begin
      FGESegment.Data := Copy(FData, StartPos, (SearchResult + FDelimiters.SDLen));
      FGESegment.Dissassemble;
    end
    else
    begin
      raise EJclEDIError.CreateResRec(@EDIError048);
    end;
  end
  else
  begin
    raise EJclEDIError.CreateResRec(@EDIError049);
  end;
  FData := '';

  FState := ediDissassembled;  
end;

//--------------------------------------------------------------------------------------------------

function TEDIFunctionalGroup.GetTransactionSet(Index: Integer): TEDITransactionSet;
begin
  if (Length(FTransactionSets) > 0) then
    if (Index >= Low(FTransactionSets)) then
      if (Index <= High(FTransactionSets)) then
      begin
        if not Assigned(FTransactionSets[Index]) then
        begin
          raise EJclEDIError.CreateResRecFmt(@EDIError038, [IntToStr(Index)]);
        end;
        Result := FTransactionSets[Index];
      end
      else
        raise EJclEDIError.CreateResRecFmt(@EDIError039, [IntToStr(Index)])
    else
      raise EJclEDIError.CreateResRecFmt(@EDIError040, [IntToStr(Index)])
  else
    raise EJclEDIError.CreateResRecFmt(@EDIError041, [IntToStr(Index)]);
end;

//--------------------------------------------------------------------------------------------------

function TEDIFunctionalGroup.InsertTransactionSet(InsertIndex: Integer): Integer;
var
  I: Integer;
begin
  Result := InsertIndex;
  if (Length(FTransactionSets) > 0) and (InsertIndex >= Low(FTransactionSets)) and
    (InsertIndex <= High(FTransactionSets)) then
  begin
    //Resize
    SetLength(FTransactionSets, Length(FTransactionSets) + 1);
    //Shift
    for I := High(FTransactionSets) downto InsertIndex + 1 do
    begin
      FTransactionSets[I] := FTransactionSets[I-1];
    end;
    //Insert
    FTransactionSets[InsertIndex] := nil;
    if Assigned(Parent) and (Parent is TEDIInterchangeControl) then
    begin
      if TEDIInterchangeControl(Parent).FEDIDUT = ediUseAsSpec then
      begin
        FTransactionSets[InsertIndex] := TEDITransactionSetSpec.Create(Self);
      end
      else
      begin
        FTransactionSets[InsertIndex] := TEDITransactionSet.Create(Self);
      end;
    end
    else
    begin
      FTransactionSets[InsertIndex] := TEDITransactionSet.Create(Self);
    end;
  end
  else
  begin
    Result := AddTransactionSet;
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDIFunctionalGroup.InsertTransactionSet(InsertIndex: Integer;
  TransactionSet: TEDITransactionSet): Integer;
var
  I: Integer;
begin
  Result := InsertIndex;
  if (Length(FTransactionSets) > 0) and (InsertIndex >= Low(FTransactionSets)) and
    (InsertIndex <= High(FTransactionSets)) then
  begin
    //Resize
    SetLength(FTransactionSets, Length(FTransactionSets) + 1);
    //Shift
    for I := High(FTransactionSets) downto InsertIndex + 1 do
    begin
      FTransactionSets[I] := FTransactionSets[I-1];
    end;
    //Insert
    FTransactionSets[InsertIndex] := nil;
    FTransactionSets[InsertIndex] := TransactionSet;
    FTransactionSets[InsertIndex].Parent := Self;
  end
  else
  begin
    Result := AppendTransactionSet(TransactionSet);
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDIFunctionalGroup.InsertTransactionSets(InsertIndex: Integer;
  TransactionSetArray: TEDITransactionSetArray): Integer;
var
  I, J, K: Integer;
begin
  Result := InsertIndex;
  I := Length(TransactionSetArray);
  if (Length(FTransactionSets) > 0) and (InsertIndex >= Low(FTransactionSets)) and
    (InsertIndex <= High(FTransactionSets)) then
  begin
    //Resize
    SetLength(FTransactionSets, Length(FTransactionSets) + I);
    //Shift
    for J := High(FTransactionSets) downto InsertIndex + I do
    begin
      FTransactionSets[J] := FTransactionSets[J-I];
      FTransactionSets[J-I] := nil;
    end;
    //Insert
    K := 0;
    for J := InsertIndex to (InsertIndex + I) - 1 do
    begin
      FTransactionSets[J] := TransactionSetArray[K];
      FTransactionSets[J].Parent := Self;
      Inc(K);
    end;
  end
  else
  begin
    Result := AppendTransactionSets(TransactionSetArray);
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDIFunctionalGroup.InsertTransactionSets(InsertIndex, Count: Integer): Integer;
var
  I: Integer;
begin
  Result := InsertIndex;
  if (Length(FTransactionSets) > 0) and (InsertIndex >= Low(FTransactionSets)) and
    (InsertIndex <= High(FTransactionSets)) then
  begin
    //Resize
    SetLength(FTransactionSets, Length(FTransactionSets) + Count);
    //Shift
    for I := High(FTransactionSets) downto InsertIndex + Count do
    begin
      FTransactionSets[I] := FTransactionSets[I-Count];
      FTransactionSets[I-Count] := nil;
    end;
    //Insert
    for I := InsertIndex to (InsertIndex + Count) - 1 do
    begin
      if Assigned(Parent) and (Parent is TEDIInterchangeControl) then
      begin
        if TEDIInterchangeControl(Parent).FEDIDUT = ediUseAsSpec then
        begin
          FTransactionSets[I] := TEDITransactionSetSpec.Create(Self);
        end
        else
        begin
          FTransactionSets[I] := TEDITransactionSet.Create(Self);
        end;
      end
      else
      begin
        FTransactionSets[I] := TEDITransactionSet.Create(Self);
      end;
    end;
  end
  else
  begin
    Result := AddTransactionSets(Count);
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDIFunctionalGroup.InternalAssignDelimiters: TEDIDelimiters;
begin
  Result := nil;
  //Attempt to assign the delimiters
  if not Assigned(FDelimiters) then
  begin
    if Assigned(Parent) and (Parent is TEDIInterchangeControl) then
    begin
      if Assigned(Parent.Delimiters) then
      begin
        Result := Parent.Delimiters;
      end;
    end;
  end;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIFunctionalGroup.SetTransactionSet(Index: Integer; TransactionSet: TEDITransactionSet);
begin
  if (Length(FTransactionSets) > 0) then
    if (Index >= Low(FTransactionSets)) then
      if (Index <= High(FTransactionSets)) then
      begin
        if Assigned(FTransactionSets[Index]) then
        begin
          FTransactionSets[Index].Free;
          FTransactionSets[Index] := nil;
        end;
        FTransactionSets[Index] := TransactionSet;
      end
      else
        raise EJclEDIError.CreateResRecFmt(@EDIError035, [IntToStr(Index)])
    else
      raise EJclEDIError.CreateResRecFmt(@EDIError036, [IntToStr(Index)])
  else
    raise EJclEDIError.CreateResRecFmt(@EDIError037, [IntToStr(Index)]);
end;

//==================================================================================================
// TEDIInterchangeControl
//==================================================================================================

function TEDIInterchangeControl.AddFunctionalGroup: Integer;
begin
  SetLength(FFunctionalGroups, Length(FFunctionalGroups) + 1);
  if FEDIDUT = ediUseAsSpec then
  begin
    FFunctionalGroups[High(FFunctionalGroups)] := TEDIFunctionalGroupSpec.Create(Self);
  end
  else
  begin
    FFunctionalGroups[High(FFunctionalGroups)] := TEDIFunctionalGroup.Create(Self);
  end;
  Result := High(FFunctionalGroups);
end;

//--------------------------------------------------------------------------------------------------

function TEDIInterchangeControl.AddFunctionalGroups(Count: Integer): Integer;
var
  I, J: Integer;
begin
  I := Length(FFunctionalGroups);
  Result := I;
  //Resize
  SetLength(FFunctionalGroups, Length(FFunctionalGroups) + Count);
  //Add
  for J := I to High(FFunctionalGroups) do
  begin
    if FEDIDUT = ediUseAsSpec then
    begin
      FFunctionalGroups[J] := TEDIFunctionalGroupSpec.Create(Self);
    end
    else
    begin
      FFunctionalGroups[J] := TEDIFunctionalGroup.Create(Self);
    end;
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDIInterchangeControl.AppendFunctionalGroup(
  FunctionalGroup: TEDIFunctionalGroup): Integer;
begin
  SetLength(FFunctionalGroups, Length(FFunctionalGroups) + 1);
  FFunctionalGroups[High(FFunctionalGroups)] := FunctionalGroup;
  FunctionalGroup.Parent := Self;
  Result := High(FFunctionalGroups);
end;

//--------------------------------------------------------------------------------------------------

function TEDIInterchangeControl.AppendFunctionalGroups(
  FunctionalGroupArray: TEDIFunctionalGroupArray): Integer;
var
  I, J, K: Integer;
begin
  I := 0;
  J := Length(FFunctionalGroups);
  Result := J;
  //Resize
  SetLength(FFunctionalGroups, Length(FFunctionalGroups) + Length(FunctionalGroupArray));
  //Append
  for K := J to High(FunctionalGroupArray) do
  begin
    FFunctionalGroups[K] := FunctionalGroupArray[I];
    FFunctionalGroups[K].Parent := Self;
    Inc(I);
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDIInterchangeControl.Assemble: string;
var
  I: Integer;
begin
  FData := '';
  FLength := 0;
  Result := '';

  if not Assigned(FDelimiters) then
  begin
    raise EJclEDIError.CreateResRec(@EDIError034);
  end;

  FData := FISASegment.Assemble;
  FISASegment.Data := '';
  FISASegment.DeleteElements;

  if (Length(FFunctionalGroups) > 0) then
  begin
    for I := Low(FFunctionalGroups) to High(FFunctionalGroups) do
    begin
      if Assigned(FFunctionalGroups[I]) then
      begin
        FData := FData + FFunctionalGroups[I].Assemble;
      end;
    end;
  end;

  DeleteFunctionalGroups;

  FData := FData + FIEASegment.Assemble;
  FIEASegment.Data := '';
  FIEASegment.DeleteElements;

  FLength := Length(FData);
  Result := FData;

  FState := ediAssembled;  
end;

//--------------------------------------------------------------------------------------------------

constructor TEDIInterchangeControl.Create(Parent: TEDIDataObject;
  EDIDUT: TEDIDataUsageType = ediUseAsData);
begin
  if Assigned(Parent) and (Parent is TEDIFile) then
  begin
    inherited Create(Parent);
  end
  else
  begin
    inherited Create(nil);
  end;
  FEDIDOT := ediInterchangeControl;
  FEDIDUT := EDIDUT;
  if FEDIDUT = ediUseAsSpec then
  begin
    FISASegment := TEDIInterchangeControlSegment(TEDIInterchangeControlSegmentSpec.Create(Self));
    FIEASegment := TEDIInterchangeControlSegment(TEDIInterchangeControlSegmentSpec.Create(Self));
  end
  else
  begin
    FISASegment := TEDIInterchangeControlSegment.Create(Self);
    FIEASegment := TEDIInterchangeControlSegment.Create(Self);
  end;
  SetLength(FFunctionalGroups, 0);
end;

//--------------------------------------------------------------------------------------------------

constructor TEDIInterchangeControl.Create(Parent: TEDIDataObject; FunctionalGroupCount: Integer;
  EDIDUT: TEDIDataUsageType = ediUseAsData);
begin
  if Assigned(Parent) and (Parent is TEDIFile) then
  begin
    inherited Create(Parent);
  end
  else
  begin
    inherited Create(nil);
  end;
  FEDIDOT := ediInterchangeControl;
  FEDIDUT := EDIDUT;
  SetLength(FFunctionalGroups, 0);
  if FEDIDUT = ediUseAsSpec then
  begin
    FISASegment := TEDIInterchangeControlSegment(TEDIInterchangeControlSegmentSpec.Create(Self));
    FIEASegment := TEDIInterchangeControlSegment(TEDIInterchangeControlSegmentSpec.Create(Self));
  end
  else
  begin
    FISASegment := TEDIInterchangeControlSegment.Create(Self);
    FIEASegment := TEDIInterchangeControlSegment.Create(Self);
  end;
  AddFunctionalGroups(FunctionalGroupCount);
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIInterchangeControl.DeleteFunctionalGroup(Index: Integer);
var
  I: Integer;
begin
  if (Length(FFunctionalGroups) > 0) and (Index >= Low(FFunctionalGroups)) and
    (Index <= High(FFunctionalGroups)) then
  begin
    //Delete
    FFunctionalGroups[Index].Free;
    FFunctionalGroups[Index] := nil;
    //Shift
    for I := Index + 1 to High(FFunctionalGroups) do
    begin
      FFunctionalGroups[I-1] := FFunctionalGroups[I];
    end;
    //Resize
    SetLength(FFunctionalGroups, High(FFunctionalGroups));
  end
  else
  begin
    raise EJclEDIError.CreateResRecFmt(@EDIError033, [IntToStr(Index)]);
  end;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIInterchangeControl.DeleteFunctionalGroups;
var
  I: Integer;
begin
  for I := Low(FFunctionalGroups) to High(FFunctionalGroups) do
  begin
    if Assigned(FFunctionalGroups[I]) then
    begin
      //Delete
      FFunctionalGroups[I].Free;
      FFunctionalGroups[I] := nil;
    end;
  end;
  //Resize
  SetLength(FFunctionalGroups, 0);
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIInterchangeControl.DeleteFunctionalGroups(Index, Count: Integer);
var
  I: Integer;
begin
  if (Length(FFunctionalGroups) > 0) and (Index >= Low(FFunctionalGroups)) and
    (Index <= High(FFunctionalGroups)) then
  begin
    //Delete
    for I := Index to (Index + Count) - 1 do
    begin
      if Assigned(FFunctionalGroups[I]) then
      begin
        FFunctionalGroups[I].Free;
        FFunctionalGroups[I] := nil;
      end;
    end;
    //Shift
    for I := (Index + Count) to High(FFunctionalGroups) do
    begin
      FFunctionalGroups[I-Count] := FFunctionalGroups[I];
      FFunctionalGroups[I] := nil;
    end;
    //Resize
    SetLength(FFunctionalGroups, Length(FFunctionalGroups) - Count);
  end
  else
  begin
    raise EJclEDIError.CreateResRecFmt(@EDIError032, [IntToStr(Index)]);
  end;
end;

//--------------------------------------------------------------------------------------------------

destructor TEDIInterchangeControl.Destroy;
begin
  FISASegment.Free;
  FIEASegment.Free;
  DeleteFunctionalGroups;
  if Assigned(FDelimiters) then
  begin
    FDelimiters.Free;
    FDelimiters := nil;
  end;
  inherited Destroy;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIInterchangeControl.Dissassemble;
var
  I, StartPos, SearchResult: Integer;
begin
  FISASegment.Data := '';
  FISASegment.DeleteElements;
  FIEASegment.Data := '';
  FIEASegment.DeleteElements;
  DeleteFunctionalGroups;

  if not Assigned(FDelimiters) then
  begin
    raise EJclEDIError.CreateResRec(@EDIError024);
  end;

  StartPos := 1;
  //Search for Interchange Control Header
  if ICHSegmentId + FDelimiters.ED = Copy(FData, 1, Length(ICHSegmentId + FDelimiters.ED)) then
  begin
    SearchResult := StrSearch(FDelimiters.SD, FData, StartPos);
    if (SearchResult - StartPos) > 0 then //data exists
    begin
      FISASegment.Data := Copy(FData, 1, (SearchResult + FDelimiters.SDLen) - 1);
      FISASegment.Dissassemble;
    end
    else
    begin
      raise EJclEDIError.CreateResRec(@EDIError025);
    end;
  end
  else
  begin
    raise EJclEDIError.CreateResRec(@EDIError026);
  end;
  //Search for Functional Group Header
  SearchResult := StrSearch(FDelimiters.SD + FGHSegmentId + FDelimiters.ED, FData, StartPos);
  if SearchResult <= 0 then
  begin
    raise EJclEDIError.CreateResRec(@EDIError027);
  end;
  //Set next start positon
  StartPos := SearchResult + FDelimiters.SDLen; //Move past the delimiter
  //Continue
  while ((StartPos + Length(FGHSegmentId)) < Length(FData)) and (SearchResult > 0) do
  begin
    //Search for Functional Group Trailer
    SearchResult := StrSearch(FDelimiters.SD + FGTSegmentId + FDelimiters.ED, FData, StartPos);
    if SearchResult > 0 then
    begin
      //Set next start positon
      SearchResult := SearchResult + FDelimiters.SDLen; //Move past the delimiter
      //Search for end of Functional Group Trailer Segment Terminator
      SearchResult := StrSearch(FDelimiters.SD, FData, SearchResult);
      if SearchResult > 0 then
      begin
        I := AddFunctionalGroup;
        FFunctionalGroups[I].Data :=
          Copy(FData, StartPos, ((SearchResult - StartPos) + FDelimiters.SDLen));
        FFunctionalGroups[I].Dissassemble;
      end
      else
      begin
        raise EJclEDIError.CreateResRec(@EDIError028);
      end;
    end
    else
    begin
      raise EJclEDIError.CreateResRec(@EDIError029);
    end;
    //Set next start positon
    StartPos := SearchResult + FDelimiters.SDLen; //Move past the delimiter
    //Verify the next record is a Functional Group Header
    if (FGHSegmentId + FDelimiters.ED) <>
      Copy(FData, StartPos, (Length(FGHSegmentId) + FDelimiters.EDLen)) then
    begin
      Break;
    end;
  end;
  //Verify the next record is a Interchange Control Trailer
  if (ICTSegmentId + FDelimiters.ED) =
    Copy(FData, StartPos, Length(ICTSegmentId + FDelimiters.ED)) then
  begin
    //Search for the end of Interchange Control Trailer Segment Terminator
    SearchResult := StrSearch(FDelimiters.SD, FData, StartPos);
    if (SearchResult - StartPos) > 0 then //data exists
    begin
      FIEASegment.Data := Copy(FData, StartPos, (SearchResult + FDelimiters.SDLen));
      FIEASegment.Dissassemble;
    end
    else
    begin
      raise EJclEDIError.CreateResRec(@EDIError030);
    end;
  end
  else
  begin
    raise EJclEDIError.CreateResRec(@EDIError031);
  end;
  FData := '';

  FState := ediDissassembled;
end;

//--------------------------------------------------------------------------------------------------

function TEDIInterchangeControl.GetFunctionalGroup(Index: Integer): TEDIFunctionalGroup;
begin
  if (Length(FFunctionalGroups) > 0) then
    if (Index >= Low(FFunctionalGroups)) then
      if (Index <= High(FFunctionalGroups)) then
      begin
        if not Assigned(FFunctionalGroups[Index]) then
        begin
          raise EJclEDIError.CreateResRecFmt(@EDIError020, [IntToStr(Index)]);
        end;
        Result := FFunctionalGroups[Index];
      end
      else
        raise EJclEDIError.CreateResRecFmt(@EDIError021, [IntToStr(Index)])
    else
      raise EJclEDIError.CreateResRecFmt(@EDIError022, [IntToStr(Index)])
  else
    raise EJclEDIError.CreateResRecFmt(@EDIError023, [IntToStr(Index)]);
end;

//--------------------------------------------------------------------------------------------------

function TEDIInterchangeControl.InsertFunctionalGroup(InsertIndex: Integer;
  FunctionalGroup: TEDIFunctionalGroup): Integer;
var
  I: Integer;
begin
  Result := InsertIndex;
  if (Length(FFunctionalGroups) > 0) and (InsertIndex >= Low(FFunctionalGroups)) and
    (InsertIndex <= High(FFunctionalGroups)) then
  begin
    //Resize
    SetLength(FFunctionalGroups, Length(FFunctionalGroups) + 1);
    //Shift
    for I := High(FFunctionalGroups) downto InsertIndex + 1 do
    begin
      FFunctionalGroups[I] := FFunctionalGroups[I-1];
    end;
    //Insert
    FFunctionalGroups[InsertIndex] := nil;
    FFunctionalGroups[InsertIndex] := FunctionalGroup;
    FFunctionalGroups[InsertIndex].Parent := Self;
  end
  else
  begin
    Result := AppendFunctionalGroup(FunctionalGroup);
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDIInterchangeControl.InsertFunctionalGroup(InsertIndex: Integer): Integer;
var
  I: Integer;
begin
  Result := InsertIndex;
  if (Length(FFunctionalGroups) > 0) and (InsertIndex >= Low(FFunctionalGroups)) and
    (InsertIndex <= High(FFunctionalGroups)) then
  begin
    //Resize
    SetLength(FFunctionalGroups, Length(FFunctionalGroups) + 1);
    //Shift
    for I := High(FFunctionalGroups) downto InsertIndex + 1 do
    begin
      FFunctionalGroups[I] := FFunctionalGroups[I-1];
    end;
    //Insert
    FFunctionalGroups[InsertIndex] := nil;
    if FEDIDUT = ediUseAsSpec then
    begin
      FFunctionalGroups[InsertIndex] := TEDIFunctionalGroupSpec.Create(Self);
    end
    else
    begin
      FFunctionalGroups[InsertIndex] := TEDIFunctionalGroup.Create(Self);
    end;
  end
  else
  begin
    Result := AddFunctionalGroup;
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDIInterchangeControl.InsertFunctionalGroups(InsertIndex, Count: Integer): Integer;
var
  I: Integer;
begin
  Result := InsertIndex;
  if (Length(FFunctionalGroups) > 0) and (InsertIndex >= Low(FFunctionalGroups)) and
    (InsertIndex <= High(FFunctionalGroups)) then
  begin
    //Resize
    SetLength(FFunctionalGroups, Length(FFunctionalGroups) + Count);
    //Shift
    for I := High(FFunctionalGroups) downto InsertIndex + Count do
    begin
      FFunctionalGroups[I] := FFunctionalGroups[I-Count];
      FFunctionalGroups[I-Count] := nil;
    end;
    //Insert
    for I := InsertIndex to (InsertIndex + Count) - 1 do
    begin
      if FEDIDUT = ediUseAsSpec then
      begin
        FFunctionalGroups[I] := TEDIFunctionalGroupSpec.Create(Self);
      end
      else
      begin
        FFunctionalGroups[I] := TEDIFunctionalGroup.Create(Self);
      end;
    end;
  end
  else
  begin
    Result := AddFunctionalGroups(Count);
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDIInterchangeControl.InsertFunctionalGroups(InsertIndex: Integer;
  FunctionalGroupArray: TEDIFunctionalGroupArray): Integer;
var
  I, J, K: Integer;
begin
  Result := InsertIndex;
  I := Length(FunctionalGroupArray);
  if (Length(FFunctionalGroups) > 0) and (InsertIndex >= Low(FFunctionalGroups)) and
    (InsertIndex <= High(FFunctionalGroups)) then
  begin
    //Resize
    SetLength(FFunctionalGroups, Length(FFunctionalGroups) + I);
    //Shift
    for J := High(FFunctionalGroups) downto InsertIndex + I do
    begin
      FFunctionalGroups[J] := FFunctionalGroups[J-I];
      FFunctionalGroups[J-I] := nil;
    end;
    //Insert
    K := 0;
    for J := InsertIndex to (InsertIndex + I) - 1 do
    begin
      FFunctionalGroups[J] := FunctionalGroupArray[K];
      FFunctionalGroups[J].Parent := Self;
      Inc(K);
    end;
  end
  else
  begin
    Result := AppendFunctionalGroups(FunctionalGroupArray);
  end;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIInterchangeControl.SetFunctionalGroup(Index: Integer;
  FunctionalGroup: TEDIFunctionalGroup);
begin
  if (Length(FFunctionalGroups) > 0) then
    if (Index >= Low(FFunctionalGroups)) then
      if (Index <= High(FFunctionalGroups)) then
      begin
        if Assigned(FFunctionalGroups[Index]) then
        begin
          FFunctionalGroups[Index].Free;
          FFunctionalGroups[Index] := nil;
        end;
        FFunctionalGroups[Index] := FunctionalGroup;
      end
      else
        raise EJclEDIError.CreateResRecFmt(@EDIError017, [IntToStr(Index)])
    else
      raise EJclEDIError.CreateResRecFmt(@EDIError018, [IntToStr(Index)])
  else
    raise EJclEDIError.CreateResRecFmt(@EDIError019, [IntToStr(Index)]);
end;

//==================================================================================================
// TEDIFile
//==================================================================================================

function TEDIFile.AddInterchange: Integer;
begin
  SetLength(FInterchanges, Length(FInterchanges) + 1);
  FInterchanges[High(FInterchanges)] := TEDIInterchangeControl.Create(Self);
  Result := High(FInterchanges);
end;

//--------------------------------------------------------------------------------------------------

function TEDIFile.AddInterchanges(Count: Integer): Integer;
var
  I, J: Integer;
begin
  I := Length(FInterchanges);
  Result := I;
  //Resize
  SetLength(FInterchanges, Length(FInterchanges) + Count);
  //Add
  for J := I to High(FInterchanges) do
  begin
    FInterchanges[J]:= TEDIInterchangeControl.Create(Self);
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDIFile.AppendInterchange(Interchange: TEDIInterchangeControl): Integer;
begin
  SetLength(FInterchanges, Length(FInterchanges) + 1);
  FInterchanges[High(FInterchanges)] := Interchange;
  FInterchanges[High(FInterchanges)].Parent := Self;
  Result := High(FInterchanges);
end;

//--------------------------------------------------------------------------------------------------

function TEDIFile.AppendInterchanges(InterchangeControlArray: TEDIInterchangeControlArray): Integer;
var
  I, J, K: Integer;
begin
  I := 0;
  J := Length(FInterchanges);
  Result := J;
  //Resize
  SetLength(FInterchanges, Length(FInterchanges) + Length(InterchangeControlArray));
  //Append
  for K := J to High(InterchangeControlArray) do
  begin
    FInterchanges[K] := InterchangeControlArray[I];
    FInterchanges[K].Parent := Self;
    Inc(I);
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDIFile.Assemble: string;
var
  I: Integer;
begin
  FData := '';
  FLength := 0;
  Result := '';

  if (Length(FInterchanges) > 0) then
  begin
    for I := Low(FInterchanges) to High(FInterchanges) do
    begin
      if Assigned(FInterchanges[I]) then
        FData := FData + FInterchanges[I].Assemble;
      FInterchanges[I].Data := '';
    end;
  end;

  FLength := Length(FData);
  Result := FData;

  DeleteInterchanges;

  FState := ediAssembled;
end;

//--------------------------------------------------------------------------------------------------

constructor TEDIFile.Create(Parent: TEDIDataObject; InterchangeCount: Integer);
begin
  if Assigned(Parent) then //and (Parent is TEDIFile)
  begin
    inherited Create(Parent);
  end
  else
  begin
    inherited Create(nil);
  end;
  FEDIFileOptions := [foVariableDelimiterDetection];
  //FErrorLog := TStringList.Create;
  FEDIDOT := ediFile;
  SetLength(FInterchanges, 0);
  AddInterchanges(InterchangeCount);
end;

//--------------------------------------------------------------------------------------------------

constructor TEDIFile.Create(Parent: TEDIDataObject);
begin
  if Assigned(Parent) then //and (Parent is TEDIFile)
  begin
    inherited Create(Parent);
  end
  else
  begin
    inherited Create(nil);
  end;
  FEDIFileOptions := [foVariableDelimiterDetection];
  //FErrorLog := TStringList.Create;
  FEDIDOT := ediFile;
  SetLength(FInterchanges, 0);
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIFile.DeleteInterchange(Index: Integer);
var
  I: Integer;
begin
  if (Length(FInterchanges) > 0) and (Index >= Low(FInterchanges)) and
    (Index <= High(FInterchanges)) then
  begin
    //Delete
    FInterchanges[Index].Free;
    FInterchanges[Index] := nil;
    //Shift
    for I := Index + 1 to High(FInterchanges) do
      FInterchanges[I-1] := FInterchanges[I];
    //Resize
    SetLength(FInterchanges, High(FInterchanges));
  end
  else
  begin
    raise EJclEDIError.CreateResRecFmt(@EDIError016, [IntToStr(Index)]);
  end;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIFile.DeleteInterchanges(Index, Count: Integer);
var
  I: Integer;
begin
  if (Length(FInterchanges) > 0) and (Index >= Low(FInterchanges)) and
    (Index <= High(FInterchanges)) then
  begin
    //Delete
    for I := Index to (Index + Count) - 1 do
    begin
      if Assigned(FInterchanges[I]) then
      begin
        FInterchanges[I].Free;
        FInterchanges[I] := nil;
      end;
    end;
    //Shift
    for I := (Index + Count) to High(FInterchanges) do
    begin
      FInterchanges[I-Count] := FInterchanges[I];
      FInterchanges[I] := nil;
    end;
    //Resize
    SetLength(FInterchanges, Length(FInterchanges) - Count);
  end
  else
  begin
    raise EJclEDIError.CreateResRecFmt(@EDIError015, [IntToStr(Index)]);
  end;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIFile.DeleteInterchanges;
var
  I: Integer;
begin
  for I := Low(FInterchanges) to High(FInterchanges) do
  begin
    if Assigned(FInterchanges[I]) then
    begin
      //Delete
      FInterchanges[I].Free;
      FInterchanges[I] := nil;
    end;
  end;
  //Resize
  SetLength(FInterchanges, 0);
end;

//--------------------------------------------------------------------------------------------------

destructor TEDIFile.Destroy;
begin
  //FErrorLog.Free;
  DeleteInterchanges;
  inherited Destroy;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIFile.Dissassemble;
var
  I, StartPos, SearchResult: Integer;
begin
  DeleteInterchanges;

  if FDelimiters = nil then
  begin
    FDelimiters := TEDIDelimiters.Create;
    FEDIFileOptions := FEDIFileOptions + [foVariableDelimiterDetection];
  end;

  FData := StringReplace(FData, AnsiCrLf, '', [rfReplaceAll, rfIgnoreCase]);
  FData := StringReplace(FData, AnsiCarriageReturn, '', [rfReplaceAll, rfIgnoreCase]);
  FData := StringReplace(FData, AnsiLineFeed, '', [rfReplaceAll, rfIgnoreCase]);

  StartPos := 1;
  //Search for Interchange Control Header
  if ICHSegmentId = Copy(FData, StartPos, Length(ICHSegmentId)) then
  begin
    SearchResult := 1;
    if (foVariableDelimiterDetection in FEDIFileOptions) then
    begin
      FDelimiters.ED := Copy(FData, Length(ICHSegmentId) + 1, 1);
      for I := 0 to 15 do
      begin
        SearchResult := StrSearch(FDelimiters.ED, FData, SearchResult);
        SearchResult := SearchResult + 1;
      end;
      FDelimiters.SS := Copy(FData, SearchResult, 1);
      FDelimiters.SD := Copy(FData, SearchResult + 1, 1);
    end;
  end
  else
  begin
    raise EJclEDIError.CreateResRec(@EDIError011);
  end;
  //Continue
  while (StartPos + Length(ICHSegmentId)) < Length(FData) do
  begin
    //Search for Interchange Control Trailer
    SearchResult := StrSearch(FDelimiters.SD + ICTSegmentId + FDelimiters.ED, FData, StartPos);
    if SearchResult > 0 then
    begin
      SearchResult := SearchResult + FDelimiters.SDLen; //Move past the delimiter
      //Search for the end of Interchange Control Trailer
      SearchResult := StrSearch(FDelimiters.SD, FData, SearchResult);
      if SearchResult > 0 then
      begin
        I := AddInterchange;
        FInterchanges[I].Delimiters :=
          TEDIDelimiters.Create(FDelimiters.SD, FDelimiters.ED, FDelimiters.SS);
        FInterchanges[I].Data :=
          Copy(FData, StartPos, ((SearchResult - StartPos) + FDelimiters.SDLen));
        FInterchanges[I].Dissassemble;
      end
      else
      begin
        raise EJclEDIError.CreateResRec(@EDIError012);
      end;
    end
    else
    begin
      raise EJclEDIError.CreateResRec(@EDIError013);
    end;
    //Set next start position, Move past the delimiter
    StartPos := SearchResult + FDelimiters.SDLen;
    //Verify the next record is an Interchange Control Header
    if ICHSegmentId = Copy(FData, StartPos, Length(ICHSegmentId)) then
    begin
      SearchResult := 1;
      if (foVariableDelimiterDetection in FEDIFileOptions) then
      begin
        FDelimiters.ED := Copy(FData, Length(ICHSegmentId) + 1, 1);
        for I := 0 to 15 do
        begin
          SearchResult := StrSearch(FDelimiters.ED, FData, SearchResult);
          SearchResult := SearchResult + 1;
        end;
        FDelimiters.SS := Copy(FData, SearchResult, 1);
        FDelimiters.SD := Copy(FData, SearchResult + 1, 1);
      end;
    end
    else if (StartPos + Length(ICHSegmentId)) < Length(FData) then
    begin
      raise EJclEDIError.CreateResRec(@EDIError014);
    end;
  end;
  FData := '';

  FState := ediDissassembled;
end;

//--------------------------------------------------------------------------------------------------

function TEDIFile.GetInterchangeControl(Index: Integer): TEDIInterchangeControl;
begin
  if (Length(FInterchanges) > 0) then
    if (Index >= Low(FInterchanges)) then
      if (Index <= High(FInterchanges)) then
      begin
        if not Assigned(FInterchanges[Index]) then
        begin
          raise EJclEDIError.CreateResRecFmt(@EDIError007, [IntToStr(Index)]);
        end;
        Result := FInterchanges[Index];
      end
      else
        raise EJclEDIError.CreateResRecFmt(@EDIError008, [IntToStr(Index)])
    else
      raise EJclEDIError.CreateResRecFmt(@EDIError009, [IntToStr(Index)])
  else
    raise EJclEDIError.CreateResRecFmt(@EDIError010, [IntToStr(Index)]);
end;

//--------------------------------------------------------------------------------------------------

function TEDIFile.InsertInterchange(InsertIndex: Integer;
  Interchange: TEDIInterchangeControl): Integer;
var
  I: Integer;
begin
  Result := InsertIndex;
  if (Length(FInterchanges) > 0) and (InsertIndex >= Low(FInterchanges)) and
    (InsertIndex <= High(FInterchanges)) then
  begin
    //Resize
    SetLength(FInterchanges, Length(FInterchanges) + 1);
    //Shift
    for I := High(FInterchanges) downto InsertIndex + 1 do
      FInterchanges[I] := FInterchanges[I-1];
    //Insert
    FInterchanges[InsertIndex] := nil;
    FInterchanges[InsertIndex] := Interchange;
    FInterchanges[InsertIndex].Parent := Self;
  end
  else
  begin
    Result := AppendInterchange(Interchange);
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDIFile.InsertInterchange(InsertIndex: Integer): Integer;
var
  I: Integer;
begin
  Result := InsertIndex;
  if (Length(FInterchanges) > 0) and (InsertIndex >= Low(FInterchanges)) and
    (InsertIndex <= High(FInterchanges)) then
  begin
    //Resize
    SetLength(FInterchanges, Length(FInterchanges) + 1);
    //Shift
    for I := High(FInterchanges) downto InsertIndex + 1 do
      FInterchanges[I] := FInterchanges[I-1];
    //Insert
    FInterchanges[InsertIndex] := nil;
    FInterchanges[InsertIndex] := TEDIInterchangeControl.Create(Self);
  end
  else
  begin
    Result := AddInterchange;
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDIFile.InsertInterchanges(InsertIndex, Count: Integer): Integer;
var
  I: Integer;
begin
  Result := InsertIndex;
  if (Length(FInterchanges) > 0) and (InsertIndex >= Low(FInterchanges)) and
    (InsertIndex <= High(FInterchanges)) then
  begin
    //Resize
    SetLength(FInterchanges, Length(FInterchanges) + Count);
    //Shift
    for I := High(FInterchanges) downto InsertIndex + Count do
    begin
      FInterchanges[I] := FInterchanges[I-Count];
      FInterchanges[I-Count] := nil;
    end;
    //Insert
    for I := InsertIndex to (InsertIndex + Count) - 1 do
    begin
      FInterchanges[I] := TEDIInterchangeControl.Create(Self);
    end;
  end
  else
  begin
    Result := AddInterchanges(Count);
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDIFile.InsertInterchanges(InsertIndex: Integer;
  InterchangeControlArray: TEDIInterchangeControlArray): Integer;
var
  I, J, K: Integer;
begin
  Result := InsertIndex;
  I := Length(InterchangeControlArray);
  if (Length(FInterchanges) > 0) and (InsertIndex >= Low(FInterchanges)) and
    (InsertIndex <= High(FInterchanges)) then
  begin
    //Resize
    SetLength(FInterchanges, Length(FInterchanges) + I);
    //Shift
    for J := High(FInterchanges) downto InsertIndex + I do
    begin
      FInterchanges[J] := FInterchanges[J-I];
      FInterchanges[J-I] := nil;
    end;
    //Insert
    K := 0;
    for J := InsertIndex to (InsertIndex + I) - 1 do
    begin
      FInterchanges[J] := InterchangeControlArray[K];
      FInterchanges[J].Parent := Self;
      Inc(K);
    end;
  end
  else
  begin
    Result := AppendInterchanges(InterchangeControlArray);
  end;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIFile.InternalLoadFromFile;
var
//Old code
//  EDIFile: file;
//  Buffer: PChar;
  EDIFileStream: TFileStream;
begin
  FData := '';
  if FFileName <> '' then
  begin
    EDIFileStream := TFileStream.Create(FFileName, fmOpenReadWrite or fmShareDenyNone);
    try
      SetLength(FData, EDIFileStream.Size);
      EDIFileStream.Read(Pointer(FData)^, EDIFileStream.Size);
    finally
      EDIFileStream.Free;
    end;
    FData := StringReplace(FData, AnsiCrLf, '', [rfReplaceAll, rfIgnoreCase]);
//Old code      
//    AssignFile(EDIFile, FFileName);
//    try
//      Reset(EDIFile, 1);
//      Buffer := StrAlloc(FileSize(EDIFile));
//      BlockRead(EDIFile, Buffer^, FileSize(EDIFile));
//      FData := Buffer;
//      FData := StringReplace(FData, AnsiCrLf, '', [rfReplaceAll, rfIgnoreCase]);
//    finally
//      CloseFile(EDIFile);
//    end;
  end
  else
  begin
    raise EJclEDIError.CreateResRec(@EDIError006);
  end;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIFile.LoadFromFile(const FileName: string);
begin
  FFileName := FileName;
  InternalLoadFromFile;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIFile.ReLoadFromFile;
begin
  InternalLoadFromFile;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIFile.SaveAsToFile(const FileName: string);
var
//Old code
//  EDIFile: file;
  EDIFileStream: TFileStream;
begin
  FFileName := FileName;
  if FFileName <> '' then
  begin
    EDIFileStream := TFileStream.Create(FFileName, fmCreate or fmShareDenyNone);
    try
      EDIFileStream.Write(Pointer(FData)^, Length(FData));
    finally
      EDIFileStream.Free;
    end;
//Old code
//    AssignFile(EDIFile, FileName);
//    try
//      ReWrite(EDIFile, 1);
//      BlockWrite(EDIFile, FData, Length(FData));
//    finally
//      CloseFile(EDIFile);
//    end;
  end
  else
  begin
    raise EJclEDIError.CreateResRec(@EDIError005);
  end;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIFile.SaveToFile;
var
//Old code
//  EDIFile: file;
  EDIFileStream: TFileStream;
begin
  if FFileName <> '' then
  begin
    EDIFileStream := TFileStream.Create(FFileName, fmCreate or fmShareDenyNone);
    try
      EDIFileStream.Write(Pointer(FData)^, Length(FData));
    finally
      EDIFileStream.Free;
    end;
//Old code
//    AssignFile(EDIFile, FFileName);
//    try
//      ReWrite(EDIFile, 1);
//      BlockWrite(EDIFile, FData, Length(FData));
//    finally
//      CloseFile(EDIFile);
//    end;
  end
  else
  begin
    raise EJclEDIError.CreateResRec(@EDIError004);
  end;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIFile.SetInterchangeControl(Index: Integer; Interchange: TEDIInterchangeControl);
begin
  if (Length(FInterchanges) > 0) then
    if (Index >= Low(FInterchanges)) then
      if (Index <= High(FInterchanges)) then
      begin
        if Assigned(FInterchanges[Index]) then
        begin
          FInterchanges[Index].Free;
          FInterchanges[Index] := nil;
        end;
        FInterchanges[Index] := Interchange
      end
      else
        raise EJclEDIError.CreateResRecFmt(@EDIError001, [IntToStr(Index)])
    else
      raise EJclEDIError.CreateResRecFmt(@EDIError002, [IntToStr(Index)])
  else
    raise EJclEDIError.CreateResRecFmt(@EDIError003, [IntToStr(Index)]);
end;

//==================================================================================================
// TEDIElementSpec
//==================================================================================================

function TEDIElementSpec.Assemble: string;
var
  Data: TStrings;
begin
  Data := TStringList.Create;
  if FId <> ElementSpecId_Reserved then
  begin
    Data.Values['Id'] := FId;
    Data.Values['Position'] := IntToStr(FPosition);
    Data.Values['Description'] := FDescription;
    Data.Values['RequirementDesignator'] := FRequirementDesignator;
    Data.Values['Type'] := FType;
    Data.Values['MinimumLength'] := IntToStr(FMinimumLength);
    Data.Values['MaximumLength'] := IntToStr(FMaximumLength);
    FData := Data.Text;
  end;
  Result := FData;
  Data.Free;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIElementSpec.Dissassemble;
var
  Data: TStrings;
begin
  Data := TStringList.Create;
  Data.Text := FData;
  if Data.Values['Id'] <> ElementSpecId_Reserved then
  begin
    FId := Data.Values['Id'];
    FPosition := StrToInt(Data.Values['Position']);
    FDescription := Data.Values['Description'];
    FRequirementDesignator := Data.Values['RequirementDesignator'];
    FType := Data.Values['Type'];
    FMinimumLength := StrToInt(Data.Values['MinimumLength']);
    FMaximumLength := StrToInt(Data.Values['MaximumLength']);
  end;
  Data.Free;
end;

//==================================================================================================
// TEDISegmentSpec
//==================================================================================================

function TEDISegmentSpec.AddElement: Integer;
begin
  SetLength(FElements, Length(FElements) + 1);
  FElements[High(FElements)] := TEDIElementSpec.Create(Self);
  Result := High(FElements); //Return position of element
end;

//--------------------------------------------------------------------------------------------------

function TEDISegmentSpec.AddElements(Count: Integer): Integer;
var
  I, J: Integer;
begin
  I := Length(FElements);
  Result := I; //Return position of 1st element
  //Resize
  SetLength(FElements, Length(FElements) + Count);
  //Add
  for J := I to High(FElements) do
  begin
    FElements[J]:= TEDIElementSpec.Create(Self);
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDISegmentSpec.Assemble: string;
var
  ReservedData: TStrings;
begin
  //Insert Segment Spec as Element[0]
  InsertElement(0);
  TEDIElementSpec(FElements[0]).Id := ElementSpecId_Reserved;
  ReservedData := TStringList.Create;
  AssembleReservedData(ReservedData);
  FElements[0].Data := ReservedData.Text;
  ReservedData.Free;
  //
  Result := inherited Assemble;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDISegmentSpec.AssembleReservedData(ReservedData: TStrings);
begin
  ReservedData.Values['Id'] := ElementSpecId_Reserved;
  ReservedData.Values['Position'] := IntToStr(FPosition);
  ReservedData.Values['Description'] := FDescription;
  ReservedData.Values['Section'] := FSection;
  ReservedData.Values['RequirementDesignator'] := FRequirementDesignator;
  ReservedData.Values['MaximumUsage'] := IntToStr(FMaximumUsage);
  if FOwnerLoopId = '' then FOwnerLoopId := NA_LoopId;
  ReservedData.Values['OwnerLoopId'] := FOwnerLoopId;
  if FParentLoopId = '' then FParentLoopId := NA_LoopId;
  ReservedData.Values['ParentLoopId'] := FParentLoopId;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDISegmentSpec.Dissassemble;
var
  ReservedData: TStrings;
begin
  inherited Dissassemble;
  //Element[0] is always the Segment Spec
  ReservedData := TStringList.Create;
  ReservedData.Text := FElements[0].Data;
  DissassembleReservedData(ReservedData);
  ReservedData.Free;
  DeleteElement(0);
end;

//--------------------------------------------------------------------------------------------------

procedure TEDISegmentSpec.DissassembleReservedData(ReservedData: TStrings);
begin
  //FSegmentId already set by the inherited Dissassemble
  FPosition := StrToInt(ReservedData.Values['Position']);
  FDescription := ReservedData.Values['Description'];
  FSection := ReservedData.Values['Section'];
  FRequirementDesignator := ReservedData.Values['RequirementDesignator'];
  FMaximumUsage := StrToInt(ReservedData.Values['MaximumUsage']);
  FOwnerLoopId := ReservedData.Values['OwnerLoopId'];
  if FOwnerLoopId = '' then FOwnerLoopId := NA_LoopId;
  FParentLoopId := ReservedData.Values['ParentLoopId'];
  if FParentLoopId = '' then FParentLoopId := NA_LoopId;
end;

//--------------------------------------------------------------------------------------------------

function TEDISegmentSpec.InsertElement(InsertIndex: Integer): Integer;
var
  I: Integer;
begin
  Result := InsertIndex;
  if (Length(FElements) > 0) and (InsertIndex >= Low(FElements)) and
    (InsertIndex <= High(FElements)) then
  begin
    //Resize
    SetLength(FElements, Length(FElements) + 1);
    //Shift
    for I := High(FElements) downto InsertIndex + 1 do
    begin
      FElements[I] := FElements[I-1];
    end;
    //Insert
    FElements[InsertIndex] := nil;
    FElements[InsertIndex] := TEDIElementSpec.Create(Self);
  end
  else
  begin
    Result := AddElement;
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDISegmentSpec.InsertElements(InsertIndex, Count: Integer): Integer;
var
  I: Integer;
begin
  Result := InsertIndex;
  if (Length(FElements) > 0) and (InsertIndex >= Low(FElements)) and
    (InsertIndex <= High(FElements)) then
  begin
    //Resize
    SetLength(FElements, Length(FElements) + Count);
    //Shift
    for I := High(FElements) downto InsertIndex + Count do
    begin
      FElements[I] := FElements[I-Count];
      FElements[I-Count] := nil;
    end;
    //Insert
    for I := InsertIndex to (InsertIndex + Count) - 1 do
    begin
      FElements[I] := TEDIElementSpec.Create(Self);
    end;
  end
  else
  begin
    Result := AddElements(Count);
  end;
end;

//==================================================================================================
// TEDITransactionSetSegmentSpec
//==================================================================================================

constructor TEDITransactionSetSegmentSpec.Create(Parent: TEDIDataObject);
begin
  inherited;
  if Assigned(Parent) and (Parent is TEDITransactionSet) then
  begin
    FParent := Parent;
  end;
end;

//--------------------------------------------------------------------------------------------------

constructor TEDITransactionSetSegmentSpec.Create(Parent: TEDIDataObject; ElementCount: Integer);
begin
  inherited;
  if Assigned(Parent) and (Parent is TEDITransactionSet) then
  begin
    FParent := Parent;
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDITransactionSetSegmentSpec.InternalAssignDelimiters: TEDIDelimiters;
begin
  Result := inherited InternalAssignDelimiters;
end;

//==================================================================================================
// TEDITransactionSetSegmentSTSpec
//==================================================================================================

procedure TEDITransactionSetSegmentSTSpec.AssembleReservedData(ReservedData: TStrings);
begin
  if Parent is TEDITransactionSetSpec then
  begin
    FTransactionSetId := TEDITransactionSetSpec(Parent).TransactionSetId;
    FTSDescription := TEDITransactionSetSpec(Parent).TSDescription;
  end;

  inherited;

  if FTransactionSetId = '' then FTransactionSetId := 'Unknown';
  ReservedData.Values['TransSetId'] := FTransactionSetId;
  if FTSDescription = '' then FTSDescription := 'None';
  ReservedData.Values['TransSetDesc'] := FTSDescription;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDITransactionSetSegmentSTSpec.DissassembleReservedData(ReservedData: TStrings);
begin
  inherited;

  FTransactionSetId := ReservedData.Values['TransSetId'];
  if FTransactionSetId = '' then FTransactionSetId := 'Unknown';
  FTSDescription := ReservedData.Values['TransSetDesc'];
  if FTSDescription = '' then FTSDescription := 'None';

  if Parent is TEDITransactionSetSpec then
  begin
    TEDITransactionSetSpec(Parent).TransactionSetId := FTransactionSetId;
    TEDITransactionSetSpec(Parent).TSDescription := FTSDescription;
  end;
end;

//==================================================================================================
// TEDIFunctionalGroupSegmentSpec
//==================================================================================================

constructor TEDIFunctionalGroupSegmentSpec.Create(Parent: TEDIDataObject);
begin
  inherited;
  if Assigned(Parent) and (Parent is TEDIFunctionalGroup) then
  begin
    FParent := Parent;
  end;
end;

//--------------------------------------------------------------------------------------------------

constructor TEDIFunctionalGroupSegmentSpec.Create(Parent: TEDIDataObject; ElementCount: Integer);
begin
  inherited;
  if Assigned(Parent) and (Parent is TEDIFunctionalGroup) then
  begin
    FParent := Parent;
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDIFunctionalGroupSegmentSpec.InternalAssignDelimiters: TEDIDelimiters;
begin
  Result := nil;
  //Attempt to assign the delimiters
  if not Assigned(FDelimiters) then
  begin
    //Get the delimiters from the functional group
    if Assigned(Parent) and (Parent is TEDIFunctionalGroup) then
    begin
      if Assigned(Parent.Delimiters) then
      begin
        Result := Parent.Delimiters;
        Exit;
      end;
      //Get the delimiters from the interchange control
      if Assigned(Parent.Parent) and (Parent.Parent is TEDIInterchangeControl) then
      begin
        if Assigned(Parent.Parent.Delimiters) then
        begin
          Result := Parent.Parent.Delimiters;
        end;
      end;
    end;
  end;
end;

//==================================================================================================
// TEDIFunctionalGroupSegmentGSSpec
//==================================================================================================

procedure TEDIFunctionalGroupSegmentGSSpec.AssembleReservedData(ReservedData: TStrings);
begin
  if Parent is TEDIFunctionalGroupSpec then
  begin
    FFunctionalGroupId := TEDIFunctionalGroupSpec(Parent).FunctionalGroupId;
    FFGDescription := TEDIFunctionalGroupSpec(Parent).FGDescription;
    FAgencyCodeId := TEDIFunctionalGroupSpec(Parent).AgencyCodeId;
    FVersionReleaseId := TEDIFunctionalGroupSpec(Parent).VersionReleaseId;
  end;

  inherited;

  if FFunctionalGroupId = '' then FFunctionalGroupId := 'Unknown';
  ReservedData.Values['FunctionalGroupId'] := FFunctionalGroupId;
  if FFGDescription = '' then FFGDescription := 'None';
  ReservedData.Values['FGDescription'] := FFGDescription;
  if FAgencyCodeId = '' then FAgencyCodeId := 'Unknown';
  ReservedData.Values['AgencyCodeId'] := FAgencyCodeId;
  if FVersionReleaseId = '' then FVersionReleaseId := 'Unknown';
  ReservedData.Values['VersionReleaseId'] := FVersionReleaseId;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDIFunctionalGroupSegmentGSSpec.DissassembleReservedData(ReservedData: TStrings);
begin
  inherited;

  FFunctionalGroupId := ReservedData.Values['FunctionalGroupId'];
  if FFunctionalGroupId = '' then FFunctionalGroupId := 'Unknown';
  FFGDescription := ReservedData.Values['FGDescription'];
  if FFGDescription = '' then FFGDescription := 'None';
  FAgencyCodeId := ReservedData.Values['AgencyCodeId'];
  if FAgencyCodeId = '' then FAgencyCodeId := 'Unknown';
  FVersionReleaseId := ReservedData.Values['VersionReleaseId'];
  if FVersionReleaseId = '' then FVersionReleaseId := 'Unknown';

  if Parent is TEDIFunctionalGroupSpec then
  begin
    TEDIFunctionalGroupSpec(Parent).FunctionalGroupId := FFunctionalGroupId;
    TEDIFunctionalGroupSpec(Parent).FGDescription := FFGDescription;
    TEDIFunctionalGroupSpec(Parent).AgencyCodeId := FAgencyCodeId;
    TEDIFunctionalGroupSpec(Parent).VersionReleaseId := FVersionReleaseId;
  end;
end;

//==================================================================================================
// TEDIInterchangeControlSegmentSpec
//==================================================================================================

constructor TEDIInterchangeControlSegmentSpec.Create(Parent: TEDIDataObject);
begin
  inherited;
  if Assigned(Parent) and (Parent is TEDIInterchangeControl) then
  begin
    FParent := Parent;
  end;
end;

//--------------------------------------------------------------------------------------------------

constructor TEDIInterchangeControlSegmentSpec.Create(Parent: TEDIDataObject; ElementCount: Integer);
begin
  inherited;
  if Assigned(Parent) and (Parent is TEDIInterchangeControl) then
  begin
    FParent := Parent;
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDIInterchangeControlSegmentSpec.InternalAssignDelimiters: TEDIDelimiters;
begin
  Result := nil;
  //Attempt to assign the delimiters
  if not Assigned(FDelimiters) then
  begin
    //Get the delimiters from the interchange control
    if Assigned(Parent) and (Parent is TEDIInterchangeControl) then
    begin
      if Assigned(Parent.Delimiters) then
      begin
        Result := Parent.Delimiters;
      end;
    end;
  end;
end;

//==================================================================================================
// TEDIFunctionalGroupSpec
//==================================================================================================

function TEDIFunctionalGroupSpec.FindTransactionSetSpec(
  TransactionSetId: string): TEDITransactionSetSpec;
var
  I: Integer;
begin
  Result := nil;
  for I := Low(FTransactionSets) to High(FTransactionSets) do
  begin
    if TransactionSetId = TEDITransactionSetSpec(FTransactionSets[I]).TransactionSetId then
    begin
      Result := TEDITransactionSetSpec(FTransactionSets[I]);
      Break;
    end;
  end;
end;

//==================================================================================================
// TEDIInterchangeControlSpec
//==================================================================================================

function TEDIInterchangeControlSpec.FindTransactionSetSpec(FunctionalGroupId, AgencyCodeId,
  VersionReleaseId, TransactionSetId: string): TEDITransactionSetSpec;
var
  F, T: Integer;
begin
  Result := nil;
  for F := Low(FFunctionalGroups) to High(FFunctionalGroups) do
  begin
    if (FunctionalGroupId = TEDIFunctionalGroupSpec(FFunctionalGroups[F]).FunctionalGroupId) and
       (AgencyCodeId = TEDIFunctionalGroupSpec(FFunctionalGroups[F]).AgencyCodeId) and
       (VersionReleaseId = TEDIFunctionalGroupSpec(FFunctionalGroups[F]).VersionReleaseId) then
    begin
      for T := Low(FFunctionalGroups[F].TransactionSets) to
        High(FFunctionalGroups[F].TransactionSets) do
      begin
        if TransactionSetId = TEDITransactionSetSpec(FFunctionalGroups[F][T]).TransactionSetId then
        begin
          Result := TEDITransactionSetSpec(FFunctionalGroups[F][T]);
          Exit;
        end;
      end; //for T := Low(FTransactionSets) to High(FTransactionSets) do
    end; //if
  end; //for F := Low(FFunctionalGroups) to High(FFunctionalGroups) do
end;

//==================================================================================================
// TEDITransactionSetLoop
//==================================================================================================

function TEDITransactionSetLoop.AddLoop(OwnerLoopId, ParentLoopId: string): Integer;
begin
  SetLength(FEDIDataObjects, Length(FEDIDataObjects) + 1);
  FEDIDataObjects[High(FEDIDataObjects)] := TEDITransactionSetLoop.Create(Self);
  TEDITransactionSetLoop(FEDIDataObjects[High(FEDIDataObjects)]).OwnerLoopId := OwnerLoopId;
  TEDITransactionSetLoop(FEDIDataObjects[High(FEDIDataObjects)]).ParentLoopId := ParentLoopId;
  Result := High(FEDIDataObjects);
end;

//--------------------------------------------------------------------------------------------------

procedure TEDITransactionSetLoop.AppendSegment(Segment: TEDISegment);
begin
  SetLength(FEDIDataObjects, Length(FEDIDataObjects) + 1);
  FEDIDataObjects[High(FEDIDataObjects)] := Segment;
end;

//--------------------------------------------------------------------------------------------------

function TEDITransactionSetLoop.Assemble: string;
begin
  Result := '';
end;

//--------------------------------------------------------------------------------------------------

constructor TEDITransactionSetLoop.Create(Parent: TEDIDataObject);
begin
  inherited Create(Parent);
  if Assigned(Parent) and (Parent is TEDITransactionSet) then
  begin
    FParentTransactionSet := TEDITransactionSet(Parent);
  end
  else if Assigned(Parent) and (Parent is TEDITransactionSetLoop) then
  begin
    FParentTransactionSet := TEDITransactionSetLoop(Parent).ParentTransactionSet;
  end
  else
  begin
    FParentTransactionSet := nil;
  end;
  FEDIDOT := ediLoop;
  SetLength(FEDIDataObjects, 0);
end;

//--------------------------------------------------------------------------------------------------

procedure TEDITransactionSetLoop.DeleteEDIDataObjects;
var
  I: Integer;
begin
  for I := Low(FEDIDataObjects) to High(FEDIDataObjects) do
  begin
    if Assigned(FEDIDataObjects[I]) then
    begin
      //Delete
      if FEDIDataObjects[I] is TEDITransactionSetLoop then
      begin
        FEDIDataObjects[I].Free;
        FEDIDataObjects[I] := nil;
      end
      else
      begin
        FEDIDataObjects[I] := nil;
      end;
    end;
  end;
  //Resize
  SetLength(FEDIDataObjects, 0);
end;

//--------------------------------------------------------------------------------------------------

destructor TEDITransactionSetLoop.Destroy;
begin
  DeleteEDIDataObjects;
  inherited;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDITransactionSetLoop.Dissassemble;
begin
  //Do Nothing
end;

//--------------------------------------------------------------------------------------------------

function TEDITransactionSetLoop.GetEDIDataObject(Index: Integer): TEDIDataObject;
begin
  if (Length(FEDIDataObjects) > 0) then
    if (Index >= Low(FEDIDataObjects)) then
      if (Index <= High(FEDIDataObjects)) then
      begin
        if not Assigned(FEDIDataObjects[Index]) then
        begin
          raise EJclEDIError.CreateResRecFmt(@EDIError075, [IntToStr(Index)]);
        end;
        Result := FEDIDataObjects[Index];
      end
      else
        raise EJclEDIError.CreateResRecFmt(@EDIError076, [IntToStr(Index)])
    else
      raise EJclEDIError.CreateResRecFmt(@EDIError077, [IntToStr(Index)])
  else
    raise EJclEDIError.CreateResRecFmt(@EDIError078, [IntToStr(Index)]);
end;

//--------------------------------------------------------------------------------------------------

procedure TEDITransactionSetLoop.SetEDIDataObject(Index: Integer; EDIDataObject: TEDIDataObject);
begin
  if (Length(FEDIDataObjects) > 0) then
    if (Index >= Low(FEDIDataObjects)) then
      if (Index <= High(FEDIDataObjects)) then
      begin
        if Assigned(FEDIDataObjects[Index]) then
        begin
          FEDIDataObjects[Index].Free;
          FEDIDataObjects[Index] := nil;
        end;
        FEDIDataObjects[Index] := EDIDataObject;
      end
      else
        raise EJclEDIError.CreateResRecFmt(@EDIError079, [IntToStr(Index)])
    else
      raise EJclEDIError.CreateResRecFmt(@EDIError080, [IntToStr(Index)])
  else
    raise EJclEDIError.CreateResRecFmt(@EDIError081, [IntToStr(Index)]);
end;

//==================================================================================================
// TEDILoopStack
//==================================================================================================

function TEDILoopStack.Add(SegmentId, OwnerLoopId, ParentLoopId: string;
  StartIndex: Integer; Loop: TEDITransactionSetLoop): Integer;
begin
  //Add to loop stack
  SetLength(FEDILoopStack, Length(FEDILoopStack) + 1);
  FEDILoopStack[High(FEDILoopStack)].SegmentId := SegmentId;
  FEDILoopStack[High(FEDILoopStack)].OwnerLoopId := OwnerLoopId;
  FEDILoopStack[High(FEDILoopStack)].ParentLoopId := ParentLoopId;
  FEDILoopStack[High(FEDILoopStack)].SpecStartIndex := StartIndex;
  FEDILoopStack[High(FEDILoopStack)].Loop := Loop;
  Result := High(FEDILoopStack);
end;

//--------------------------------------------------------------------------------------------------

constructor TEDILoopStack.Create;
begin
  inherited;
  SetLength(FEDILoopStack, 0);
end;

//--------------------------------------------------------------------------------------------------

function TEDILoopStack.Debug: string;
var
  I: Integer;
begin
  Result := 'Loop Stack' + #13#10;
  for I := 0 to High(FEDILoopStack) do
  begin
    Result := Result + FEDILoopStack[I].SegmentId + ', ';
    Result := Result + FEDILoopStack[I].OwnerLoopId + ', ';
    Result := Result + FEDILoopStack[I].ParentLoopId + ', ';
    Result := Result + IntToStr(FEDILoopStack[I].SpecStartIndex) + #13#10;
  end;
end;

//--------------------------------------------------------------------------------------------------

destructor TEDILoopStack.Destroy;
begin
  SetLength(FEDILoopStack, 0);
  inherited;
end;

//--------------------------------------------------------------------------------------------------

function TEDILoopStack.GetStackRecord: TEDILoopStackRecord;
begin
  Result := FEDILoopStack[High(FEDILoopStack)];
end;

//--------------------------------------------------------------------------------------------------

function TEDILoopStack.GetSafeStackIndex(Index: Integer): Integer;
begin
  if (Length(FEDILoopStack) > 0) then
    if (Index >= Low(FEDILoopStack)) then
      if (Index <= High(FEDILoopStack)) then
      begin
        Result := Index;
      end
      else
      begin
        Result := High(FEDILoopStack);
      end
    else
    begin
      Result := Low(FEDILoopStack);
    end
  else
  begin
    raise EJclEDIError.CreateResRecFmt(@EDIError086, [IntToStr(Index)]);
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDILoopStack.GetStackRecord(Index: Integer): TEDILoopStackRecord;
begin
  if (Length(FEDILoopStack) > 0) then
    if (Index >= Low(FEDILoopStack)) then
      if (Index <= High(FEDILoopStack)) then
      begin
        if not Assigned(FEDILoopStack[Index].Loop) then
        begin
          raise EJclEDIError.CreateResRecFmt(@EDIError082, [IntToStr(Index)]);
        end;
        Result := FEDILoopStack[Index];
      end
      else
        raise EJclEDIError.CreateResRecFmt(@EDIError083, [IntToStr(Index)])
    else
      raise EJclEDIError.CreateResRecFmt(@EDIError084, [IntToStr(Index)])
  else
    raise EJclEDIError.CreateResRecFmt(@EDIError085, [IntToStr(Index)]);
end;

//--------------------------------------------------------------------------------------------------

function TEDILoopStack.GetStackSize: Integer;
begin
  Result := Length(FEDILoopStack);
end;

//--------------------------------------------------------------------------------------------------

function TEDILoopStack.SetStackPointer(OwnerLoopId, ParentLoopId: string): Integer;
var
  I: Integer;
begin
  FStackResized := False;
  FAltStackPointer := False;
  Result := -1; //Entry not found
  //Find the loop in the stack
  for I := High(FEDILoopStack) downto 0 do
  begin
    if (OwnerLoopId = FEDILoopStack[I].OwnerLoopId) and
       (ParentLoopId = FEDILoopStack[I].ParentLoopId) then
    begin
      Result := I;
      //Resize loop stack if entry found is less than high entry
      if I < High(FEDILoopStack) then
      begin
        SetLength(FEDILoopStack, I + 1);
        FStackResized := True;
      end;
      Break;
    end;
  end; //for I := High(FEDILoopStack) downto 0 do
  //Check if an exact entry was found
  if Result = -1 then
  begin
    //Find the parent loop in the stack
    for I := High(FEDILoopStack) downto 0 do
    begin
      if (ParentLoopId = FEDILoopStack[I].ParentLoopId) and
         (FEDILoopStack[I].OwnerLoopId <> NA_LoopId) then
      begin
        FAltStackPointer := True;
        Result := GetSafeStackIndex(I+1);
        Break;
      end;
    end; //for I := High(FEDILoopStack) downto 0 do
  end; //if Result = -1 then
end;

//--------------------------------------------------------------------------------------------------

procedure TEDILoopStack.Update(SegmentId, OwnerLoopId, ParentLoopId: string;
  StartIndex: Integer; Loop: TEDITransactionSetLoop);
begin
  FEDILoopStack[High(FEDILoopStack)].SegmentId := SegmentId;
  FEDILoopStack[High(FEDILoopStack)].OwnerLoopId := OwnerLoopId;
  FEDILoopStack[High(FEDILoopStack)].ParentLoopId := ParentLoopId;
  FEDILoopStack[High(FEDILoopStack)].SpecStartIndex := StartIndex;
  FEDILoopStack[High(FEDILoopStack)].Loop := Loop;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDILoopStack.UpdateLoopReference(Loop: TEDITransactionSetLoop);
begin
  FEDILoopStack[High(FEDILoopStack)].Loop := Loop;
end;

//==================================================================================================
// TEDITransactionSetDocument
//==================================================================================================

procedure TEDITransactionSetDocument.FormatDocument;
var
  I, J: Integer;
  LSR: TEDILoopStackRecord;
  LoopRepeated: Boolean;
  DataSegment: TEDISegment;
  SpecSegment: TEDISegmentSpec;
begin
  I := 0;
  J := 0;
  //Initialize the stack
  LSR := ValidateLoopStack(FEDITransactionSet.Segment[I].SegmentID,
                           NA_LoopId, NA_LoopId, 0, Self, False);
  //
  while (I <= High(FEDITransactionSet.Segments)) and (J <= High(FEDITransactionSetSpec.Segments)) do
  begin
    LoopRepeated := False;
    DataSegment := FEDITransactionSet.Segment[I];
    //If loop has repeated then move the spec index back
    J := ValidateSegSpecIndex(DataSegment.SegmentID, J, LoopRepeated);
    //Check current segment against segment spec
    SpecSegment := TEDISegmentSpec(FEDITransactionSetSpec.Segment[J]);
    if DataSegment.SegmentID = SpecSegment.SegmentID then
    begin
      //Retrieve the correct record to use from the stack
      LSR := ValidateLoopStack(SpecSegment.SegmentID, SpecSegment.OwnerLoopId,
                               SpecSegment.ParentLoopId, J, LSR.Loop, LoopRepeated);
      //
      //Debug - Keep the following line here in case someone wants to debug what happens to the stack.
      //ShowMessage('Current Data Segment: [' + IntToStr(I) + '] ' + DataSegment.SegmentID + #13#10 +
      //            'Current Spec Segment: [' + IntToStr(J) + '] ' + SpecSegment.SegmentID + #13#10 +
      //            FEDILoopStack.Debug);
      //
      //Do error checking and data validation in decendent class
      ValidateData(Self, FEDILoopStack, DataSegment, SpecSegment, I, J, FErrorOccured);
      if FErrorOccured then Exit;
      //Process Segment Id
      LSR.Loop.AppendSegment(DataSegment);
      //Move to the next data segment
      Inc(I);
    end
    else
    begin
      //Do error checking and data validation in decendent class
      ValidateData(Self, FEDILoopStack, DataSegment, SpecSegment, I, J, FErrorOccured);
      if FErrorOccured then Exit;
      //
      //Debug - Keep the following line here in case someone wants to debug what happens to the stack.
      //ShowMessage('Current Data Segment: [' + IntToStr(I) + '] ' + DataSegment.SegmentID + #13#10 +
      //            'Current Spec Segment: [' + IntToStr(J) + '] ' + SpecSegment.SegmentID + #13#10 +
      //            FEDILoopStack.Debug);
      //
      //Move to the next specification segment
      J := AdvanceSegSpecIndex(I, J, High(FEDITransactionSetSpec.Segments)); //Inc(J);
    end;
  end; //while I <= High(EDITransactionSet.Segments) do
end;

//--------------------------------------------------------------------------------------------------

constructor TEDITransactionSetDocument.Create(Parent: TEDIDataObject;
  EDITransactionSet: TEDITransactionSet;
  EDITransactionSetSpec: TEDITransactionSetSpec);
begin
  inherited Create(Parent);
  FEDILoopStack := TEDILoopStack.Create;
  FEDITransactionSet := EDITransactionSet;
  FEDITransactionSetSpec := EDITransactionSetSpec;
end;

//--------------------------------------------------------------------------------------------------

destructor TEDITransactionSetDocument.Destroy;
begin
  FEDILoopStack.Free;
  inherited;
end;

//--------------------------------------------------------------------------------------------------

procedure TEDITransactionSetDocument.ValidateData(
  TSDocument: TEDITransactionSetDocument; LoopStack: TEDILoopStack;
  DataSegment, SpecSegment: TEDISegment; var DataIndex, SpecIndex: Integer;
  var ErrorOccured: Boolean);
begin
  ErrorOccured := False;
end;

//--------------------------------------------------------------------------------------------------

function TEDITransactionSetDocument.AdvanceSegSpecIndex(DataIndex, SpecStartIndex,
  SpecEndIndex: Integer): Integer;
var
  DataSegment: TEDISegment;
  TestSegment: TEDISegmentSpec;
  I: Integer;
begin
  Result := SpecEndIndex + 1;
  DataSegment := FEDITransactionSet.Segment[DataIndex];
  for I := SpecStartIndex + 1 to SpecEndIndex do
  begin
    TestSegment := TEDISegmentSpec(FEDITransactionSetSpec.Segment[I]);
    //Find matching segment
    if ((DataSegment.SegmentID) = (TestSegment.SegmentID)) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

//--------------------------------------------------------------------------------------------------

function TEDITransactionSetDocument.ValidateLoopStack(SpecSegmentId, SpecOwnerLoopId,
  SpecParentLoopId: string; SpecStartIndex: Integer; Loop: TEDITransactionSetLoop;
  LoopRepeated: Boolean): TEDILoopStackRecord;
var
  I: Integer;
  SR: TEDILoopStackRecord;
begin
  if FEDILoopStack.GetStackSize <= 0 then
  begin
    //Add entry to stack
    FEDILoopStack.Add(SpecSegmentId, SpecOwnerLoopId, SpecParentLoopId, SpecStartIndex, Loop);
  end
  else //FEDILoopStack.GetStackSize > 0
  begin
    I := FEDILoopStack.SetStackPointer(SpecOwnerLoopId, SpecParentLoopId);
    if I >= 0 then //Entry found
    begin
      if LoopRepeated then
      begin
        SR := FEDILoopStack.GetStackRecord(I-1);
        //Add loop since it repeated
        I := SR.Loop.AddLoop(SpecOwnerLoopId, SpecParentLoopId);
        //Update stack loop with new loop reference
        FEDILoopStack.UpdateLoopReference(TEDITransactionSetLoop(SR.Loop[I]));
        //Debug
        //ShowMessage('LoopRepeated');
      end
      else if FEDILoopStack.AltStackPointer then
      begin
        SR := FEDILoopStack.GetStackRecord(I-1);
        //Add loop since it is new
        I := SR.Loop.AddLoop(SpecOwnerLoopId, SpecParentLoopId);
        //Update stack entry
        FEDILoopStack.Update(SpecSegmentId, SpecOwnerLoopId, SpecParentLoopId, SpecStartIndex,
                             TEDITransactionSetLoop(SR.Loop[I]));
        //Debug
        //ShowMessage('AltStackPointer');
      end
      else if FEDILoopStack.StackResized then
      begin
        //Debug
        //ShowMessage('Stack Size Decreased');
      end
      else
      begin
        //Segment is part of loop
      end;
    end
    else if (I = -1) then //Entry not found.
    begin
      I := Loop.AddLoop(SpecOwnerLoopId, SpecParentLoopId);
      //Add entry to stack
      FEDILoopStack.Add(SpecSegmentId, SpecOwnerLoopId, SpecParentLoopId, SpecStartIndex,
                        TEDITransactionSetLoop(Loop[I]));
      //Debug
      //ShowMessage('Stack Size Increased');
    end; //if I >= 0 then
  end; //if Length(FEDILoopStack) <= 0 then
  Result := FEDILoopStack.GetStackRecord;
end;

//--------------------------------------------------------------------------------------------------

function TEDITransactionSetDocument.ValidateSegSpecIndex(DataSegmentId: string;
  SpecStartIndex: Integer; var LoopRepeated: Boolean): Integer;
var
  I: Integer;
begin
  Result := SpecStartIndex;
  //Find the segment in the stack to determine if a loop has repeated
  for I := High(FEDILoopStack.Stack) downto Low(FEDILoopStack.Stack) do
  begin
    if (DataSegmentId = FEDILoopStack.Stack[I].SegmentId) and
       (FEDILoopStack.Stack[I].OwnerLoopId <> NA_LoopId) then
    begin
      LoopRepeated := True;
      Result := FEDILoopStack.Stack[I].SpecStartIndex;
      Break;
    end;
  end; //for I := High(FEDILoopStack) downto 0 do
end;

//--------------------------------------------------------------------------------------------------

end.
