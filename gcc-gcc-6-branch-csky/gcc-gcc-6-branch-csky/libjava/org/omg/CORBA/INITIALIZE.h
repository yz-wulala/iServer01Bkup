
// DO NOT EDIT THIS FILE - it is machine generated -*- c++ -*-

#ifndef __org_omg_CORBA_INITIALIZE__
#define __org_omg_CORBA_INITIALIZE__

#pragma interface

#include <org/omg/CORBA/SystemException.h>
extern "Java"
{
  namespace org
  {
    namespace omg
    {
      namespace CORBA
      {
          class CompletionStatus;
          class INITIALIZE;
      }
    }
  }
}

class org::omg::CORBA::INITIALIZE : public ::org::omg::CORBA::SystemException
{

public:
  INITIALIZE(::java::lang::String *);
  INITIALIZE();
  INITIALIZE(jint, ::org::omg::CORBA::CompletionStatus *);
  INITIALIZE(::java::lang::String *, jint, ::org::omg::CORBA::CompletionStatus *);
private:
  static const jlong serialVersionUID = -3753094599663690309LL;
public:
  static ::java::lang::Class class$;
};

#endif // __org_omg_CORBA_INITIALIZE__