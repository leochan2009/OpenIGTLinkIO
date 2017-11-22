/*==========================================================================

  Portions (c) Copyright 2008-2009 Brigham and Women's Hospital (BWH) All Rights Reserved.

  See Doc/copyright/copyright.txt
  or http://www.slicer.org/copyright/copyright.txt for details.

  Program:   3D Slicer
  Module:    $HeadURL: http://svn.slicer.org/Slicer4/trunk/Modules/OpenIGTLinkIF/vtkSlicerOpenIGTLinkIFLogic.cxx $
  Date:      $Date: 2011-06-12 14:55:20 -0400 (Sun, 12 Jun 2011) $
  Version:   $Revision: 16985 $

==========================================================================*/

#include <algorithm>
// IGTLIO includes
#include "igtlioLogic.h"
#include "igtlioConnector.h"
#include "igtlioSession.h"

#include <vtkObjectFactory.h>

// OpenIGTLinkIF Logic includes
#include <vtkNew.h>
#include <vtkCallbackCommand.h>
#include <vtkImageData.h>
#include <vtkTransform.h>


namespace igtlio
{
//---------------------------------------------------------------------------
vtkStandardNewMacro(Logic);


//---------------------------------------------------------------------------
Logic::Logic()
{
}

//---------------------------------------------------------------------------
Logic::~Logic()
{
}

//---------------------------------------------------------------------------
void Logic::PrintSelf(ostream& os, vtkIndent indent)
{
  os << indent << "vtkIGTLIOLogic:             " << this->GetClassName() << "\n";
}

//---------------------------------------------------------------------------
void Logic::onDeviceEventFunc(vtkObject *caller, unsigned long event, void *callData)
{
  if ((event==CommandReceivedEvent) ||
      (event==CommandResponseReceivedEvent))
  {
    this->InvokeEvent(event, callData);
  }
}

//---------------------------------------------------------------------------
void Logic::onNewDeviceEventFunc(vtkObject *caller, unsigned long event, void *callData)
{
  this->InvokeEvent(Logic::NewDeviceEvent, callData);

  Device* device = reinterpret_cast<Device*>(callData);
  this->CommandReceivedEventTag = device->AddObserver(CommandReceivedEvent, this, &igtlio::Logic::onDeviceEventFunc);
  this->CommandResponseReceivedEventTag = device->AddObserver(CommandResponseReceivedEvent, this, &igtlio::Logic::onDeviceEventFunc);
}

//---------------------------------------------------------------------------
void Logic::onRemovedDeviceEventFunc(vtkObject *caller, unsigned long event, void *callData)
{
  this->InvokeEvent(Logic::RemovedDeviceEvent, callData);

  Device* device = reinterpret_cast<Device*>(callData);
  device->RemoveObserver(this->CommandReceivedEventTag);
  device->RemoveObserver(this->CommandResponseReceivedEventTag);
}

//---------------------------------------------------------------------------
ConnectorPointer Logic::CreateConnector()
{
  ConnectorPointer connector = ConnectorPointer::New();
  connector->SetUID(this->CreateUniqueConnectorID());
  std::stringstream ss;
  ss << "IGTLConnector_" << connector->GetUID();
  connector->SetName(ss.str());
  Connectors.push_back(connector);

  this->NewDeviceEventTag = connector->AddObserver(Connector::NewDeviceEvent, this, &Logic::onNewDeviceEventFunc);
  this->RemoveDeviceEventTag = connector->AddObserver(Connector::RemovedDeviceEvent, this, &Logic::onRemovedDeviceEventFunc);

  this->InvokeEvent(ConnectionAddedEvent, connector.GetPointer());
  return connector;
}

//---------------------------------------------------------------------------
int Logic::CreateUniqueConnectorID() const
{
  int retval=0;
  for (unsigned int i=0; i<Connectors.size(); ++i)
    {
      retval = std::max<int>(retval, Connectors[i]->GetUID()+1);
    }
  return retval;
}

//---------------------------------------------------------------------------
int Logic::RemoveConnector(unsigned int index)
{
  std::vector<ConnectorPointer>::iterator toRemove = Connectors.begin()+index;

  toRemove->GetPointer()->RemoveObserver(this->NewDeviceEventTag);
  toRemove->GetPointer()->RemoveObserver(this->RemoveDeviceEventTag);

  this->InvokeEvent(ConnectionAboutToBeRemovedEvent, toRemove->GetPointer());
  Connectors.erase(toRemove);
  return 0;
}

//---------------------------------------------------------------------------
int Logic::GetNumberOfConnectors() const
{
  return Connectors.size();
}

//---------------------------------------------------------------------------
ConnectorPointer Logic::GetConnector(unsigned int index)
{
  if (index<Connectors.size())
    return Connectors[index];

  vtkErrorMacro("index " << index << " out of bounds.");
  return NULL;
}

SessionPointer Logic::StartServer(int serverPort, igtlio::SYNCHRONIZATION_TYPE sync, double timeout_s)
{
  SessionPointer session = SessionPointer::New();
  session->SetConnector(this->CreateConnector());
  session->StartServer(serverPort, sync, timeout_s);
  return session;
}

SessionPointer Logic::ConnectToServer(std::string serverHost, int serverPort, igtlio::SYNCHRONIZATION_TYPE sync, double timeout_s)
{
  SessionPointer session = SessionPointer::New();
  session->SetConnector(this->CreateConnector());
  session->ConnectToServer(serverHost, serverPort, sync, timeout_s);
  return session;
}

//---------------------------------------------------------------------------
void Logic::PeriodicProcess()
{
  for (unsigned i=0; i<Connectors.size(); ++i)
    {
      Connectors[i]->PeriodicProcess();
    }
}

//---------------------------------------------------------------------------
unsigned int Logic::GetNumberOfDevices() const
{
  std::vector<DevicePointer> all = this->CreateDeviceList();
  return all.size();
}

//---------------------------------------------------------------------------
void Logic::RemoveDevice(unsigned int index)
{
  DevicePointer device = this->GetDevice(index);

  for (unsigned i=0; i<Connectors.size(); ++i)
    {
      for (unsigned j=0; j<Connectors[i]->GetNumberOfDevices(); ++j)
        {
          DevicePointer local = Connectors[i]->GetDevice(j);
          if (device==local)
            Connectors[i]->RemoveDevice(j);
        }
    }
}

//---------------------------------------------------------------------------
DevicePointer Logic::GetDevice(unsigned int index)
{
  // TODO: optimize by caching the vector if necessary
  std::vector<DevicePointer> all = this->CreateDeviceList();

  if (index<all.size())
    return all[index];

  vtkErrorMacro("index " << index << " out of bounds.");
  return NULL;
}

//---------------------------------------------------------------------------
int Logic::ConnectorIndexFromDevice( DevicePointer d )
{
    for( std::vector<ConnectorPointer>::size_type i = 0; i < Connectors.size(); ++i )
        if( Connectors[i]->HasDevice(d) )
            return i;
    return -1;
}

//---------------------------------------------------------------------------
std::vector<DevicePointer> Logic::CreateDeviceList() const
{
  std::set<DevicePointer> all;

  for (unsigned i=0; i<Connectors.size(); ++i)
    {
      for (unsigned j=0; j<Connectors[i]->GetNumberOfDevices(); ++j)
        {
          all.insert(Connectors[i]->GetDevice(j));
        }
    }

  return std::vector<DevicePointer>(all.begin(), all.end());
}

} // namespace igtlio

