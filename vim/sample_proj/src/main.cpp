#include <iostream>
#include <initializer_list>
#include <chrono>


using std::cout;
using std::endl;
using std::initializer_list;

class A
{
  public:
    A() : mInt(1)
    {
      cout << "A::A()" << endl;
    }

    A(int i) : mInt(i)
    {
      cout << "A::A(int)" << endl;
    }

    A(std::initializer_list<int> l)
    {
      cout << "A::A(initializer_list<int>)" << endl;
      for (auto listItem : l)
      {
        mInt = listItem;
      }
    }

    A& operator=(const A& src)
    {
      cout << "A::operator=(A&)" << endl;
      if (this != &src)
       {
         mInt = src.mInt;
       }
       return *this;
    }

    A& operator=(const initializer_list<int>& src)
    {
      cout << "A::operator=(initializer)" << endl;

    }

    int mInt;
};

int main(int argc, char**argv)
{
  using std::chrono::high_resolution_clock;  
  using std::cerr;
  const int reps{10};

  std::ios::sync_with_stdio(false);

  std::string test{"Test"};
  //cout << test << endl;
  auto start = high_resolution_clock::now();
  auto stop = high_resolution_clock::now();

  start = high_resolution_clock::now();
  for(int i=0; i< reps; i++)
  cout << test + 'c'; 
  stop = high_resolution_clock::now();
  cout << endl;
  cerr << "cout << test + \'c\'; (" <<  std::chrono::duration_cast<std::chrono::milliseconds>(stop-start).count() << "ms)" << endl;

  return 0;
}
