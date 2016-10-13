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
 * Three20 Debugging tools.
 *
 * Provided in this header are a set of debugging tools. This is meant quite literally, in that
 * all of the macros below will only function when the DEBUG preprocessor macro is specified.
 *
 * BMTTDASSERT(<statement>);
 * If <statement> is false, the statement will be written to the log and if you are running in
 * the simulator with a debugger attached, the app will break on the assertion line.
 *
 * BMTTDPRINT(@"formatted log text %d", param1);
 * Print the given formatted text to the log.
 *
 * BMTTDPRINTMETHODNAME();
 * Print the current method name to the log.
 *
 * BMTTDCONDITIONLOG(<statement>, @"formatted log text %d", param1);
 * If <statement> is true, then the formatted text will be written to the log.
 *
 * BMTTDINFO/BMTTDWARNING/BMTTDERROR(@"formatted log text %d", param1);
 * Will only write the formatted text to the log if BMTTMAXLOGLEVEL is greater than the respective
 * BMTTD* method's log level. See below for log levels.
 *
 * The default maximum log level is BMTTLOGLEVEL_WARNING.
 */

#define BMTTLOGLEVEL_INFO     5
#define BMTTLOGLEVEL_WARNING  3
#define BMTTLOGLEVEL_ERROR    1

#ifndef BMTTMAXLOGLEVEL
  #define BMTTMAXLOGLEVEL BMTTLOGLEVEL_WARNING
#endif

// The general purpose logger. This ignores logging levels.
#ifdef DEBUG
  #define BMTTDPRINT(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
  #define BMTTDPRINT(xx, ...)  ((void)0)
#endif // #ifdef DEBUG

// Prints the current method's name.
#define BMTTDPRINTMETHODNAME() BMTTDPRINT(@"%s", __PRETTY_FUNCTION__)

// Debug-only assertions.
#ifdef DEBUG

#import <TargetConditionals.h>

#if TARGET_IPHONE_SIMULATOR

  int BMTTIsInDebugger();
  // We leave the __asm__ in this macro so that when a break occurs, we don't have to step out of
  // a "breakInDebugger" function.
  #define BMTTDASSERT(xx) { if (!(xx)) { BMTTDPRINT(@"BMTTDASSERT failed: %s", #xx); \
                                      if (BMTTIsInDebugger()) { __asm__("int $3\n" : : ); }; } \
                        } ((void)0)
#else
  #define BMTTDASSERT(xx) { if (!(xx)) { BMTTDPRINT(@"BMTTDASSERT failed: %s", #xx); } } ((void)0)
#endif // #if TARGET_IPHONE_SIMULATOR

#else
  #define BMTTDASSERT(xx) ((void)0)
#endif // #ifdef DEBUG

// Log-level based logging macros.
#if BMTTLOGLEVEL_ERROR <= BMTTMAXLOGLEVEL
  #define BMTTDERROR(xx, ...)  BMTTDPRINT(xx, ##__VA_ARGS__)
#else
  #define BMTTDERROR(xx, ...)  ((void)0)
#endif // #if BMTTLOGLEVEL_ERROR <= BMTTMAXLOGLEVEL

#if BMTTLOGLEVEL_WARNING <= BMTTMAXLOGLEVEL
  #define BMTTDWARNING(xx, ...)  BMTTDPRINT(xx, ##__VA_ARGS__)
#else
  #define BMTTDWARNING(xx, ...)  ((void)0)
#endif // #if BMTTLOGLEVEL_WARNING <= BMTTMAXLOGLEVEL

#if BMTTLOGLEVEL_INFO <= BMTTMAXLOGLEVEL
  #define BMTTDINFO(xx, ...)  BMTTDPRINT(xx, ##__VA_ARGS__)
#else
  #define BMTTDINFO(xx, ...)  ((void)0)
#endif // #if BMTTLOGLEVEL_INFO <= BMTTMAXLOGLEVEL

#ifdef DEBUG
  #define BMTTDCONDITIONLOG(condition, xx, ...) { if ((condition)) { \
                                                  BMTTDPRINT(xx, ##__VA_ARGS__); \
                                                } \
                                              } ((void)0)
#else
  #define BMTTDCONDITIONLOG(condition, xx, ...) ((void)0)
#endif // #ifdef DEBUG
