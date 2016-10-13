//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/**
 * These flags are used primarily by BMTTDCONDITIONLOG.
 * Example:
 *
 *    BMTTDCONDITIONLOG(BMTTDFLAG_NAVIGATOR, @"BMTTNavigator activated");
 *
 * This will only write to the log if the BMTTDFLAG_NAVIGATOR is set to non-zero.
 */
#define BMTTDFLAG_VIEWCONTROLLERS             0
#define BMTTDFLAG_CONTROLLERGARBAGECOLLECTION 0
#define BMTTDFLAG_NAVIGATOR                   0
#define BMTTDFLAG_TABLEVIEWMODIFICATIONS      0
#define BMTTDFLAG_LAUNCHERVIEW                0
#define BMTTDFLAG_URLREQUEST                  0
#define BMTTDFLAG_URLCACHE                    0
#define BMTTDFLAG_XMLPARSER                   0
#define BMTTDFLAG_ETAGS                       0
