import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: loginPage()
    );
  }
}

class AppNav extends StatefulWidget{
  const AppNav({super.key});

  @override
  State<AppNav> createState() =>
  _AppNavState();
}


void saveInput(){

}


class _AppNavState extends State<AppNav> {
  int currentPageIndex = 1;
  
  String name = "User_0001";
  String phoneNumber = "123-456-7890";
  String address = "123 Sample St.";
  String city = "__city__";
  String state = "XX";
  String zipcode = "12345";
  String email = "sample@email.com";

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);


    return Scaffold(
      appBar: AppBar(title: Text("App Testing")),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: const Color.fromARGB(255, 164, 183, 231),
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Badge(child: Icon(Icons.notifications_sharp)),
            label: 'Notifications',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),

        ],
      ),
      body: <Widget>[
        
        /// Notifications page
        Card(
          margin: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[

              //each notification will be an example of this VVV
              Card(
                child: ListTile(
                  leading: Icon(Icons.notifications_sharp),
                  title: Text('Notification Title'),
                  subtitle: Text('Text for Notification here!!'),
                  onTap: (){

                  },
                  
                ),
              ),
            ],
          ),
        ),
        
        
        /// Home page -- Needs contents added
        Card(
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              
              Card(
                child: ListTile(
                  leading: Icon(Icons.pin_drop),
                  title: Text('Chat for: ____'),
                  subtitle: Text('latest pinned message'),
                  onTap: () {
                    Navigator.push(
                      context, MaterialPageRoute(builder: (context) => const ChatPage())
                    );
                  },
                )
              )
            ],)
        ),




        //profile -- currently for the edit profile section, 
        Card(
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20,),
              Text('Profile', style: theme.textTheme.titleLarge),
              SizedBox(height: 20,),
              Text('Name: '+ name, style: theme.textTheme.bodyLarge),
              SizedBox(height: 20,),
              Text('Address: '+ address, style: theme.textTheme.bodyLarge),
              SizedBox(height: 20,),
              Text(city + ', ' + state + '; ' + zipcode, style: theme.textTheme.bodyLarge),
              SizedBox(height: 20,),
              Text('Phone: '+ phoneNumber, style: theme.textTheme.bodyLarge),
              SizedBox(height: 20,),
              Text('email: '+ email, style: theme.textTheme.bodyLarge),
              SizedBox(height: 20,),
              SizedBox(width: double.infinity),

              ElevatedButton(
                child: const Text('Edit'),
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll<Color>(Colors.blue.shade100),
                ),
                onPressed: (){
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => const editProfilePage())
                    );
                }
                ),
            ],
          ),
          

        ),

        /// Profile page
        
      ][currentPageIndex],
    );
  }
}

class ChatPage extends StatelessWidget{
  const ChatPage ({super.key});
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text ('-location- page')),
      body: Center(
        //Content for the page
    ),
    );
  }
}


class editProfilePage extends StatelessWidget{
  const editProfilePage ({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold (
      appBar: AppBar(title: const Text ('Edit Profile Page')),
      body: SingleChildScrollView(
        child:Column(
          children: <Widget>[
            //spacer, include icon in this if wanted
            Padding(
              padding: const EdgeInsets.only(top:175.0),
            ),

            //username text field
            Padding(
              padding: const EdgeInsets.only(left: 10,right: 10, top: 10),
              child:TextField(
                decoration:InputDecoration(
                  border:OutlineInputBorder(),
                  labelText: 'Enter Username',
                  hintText: "Enter valid username", 
                ),
              ),
            ),

            //email text field
            Padding(
              padding: const EdgeInsets.only(left: 10,right: 10, top: 10),
              child:TextField(
                decoration:InputDecoration(
                  border:OutlineInputBorder(),
                  labelText: 'Enter email',
                  hintText: "Enter valid email", 
                ),
              ),
            ),

            //phone text field
            Padding(
              padding: const EdgeInsets.only(left: 10,right: 10, top: 10),
              child:TextField(
                decoration:InputDecoration(
                  border:OutlineInputBorder(),
                  labelText: 'Enter phone number',
                  hintText: "Enter valid phone number", 
                ),
              ),
            ),



            //password text field
            Padding(padding: const EdgeInsets.only(left: 10,right: 10, top: 10),
            child: TextField(
              
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
                hintText: 'Enter valid password',
              ),
            ),
            ),
            // confirm password
            Padding(padding: const EdgeInsets.only(left: 10,right: 10, top: 10),
            child: TextField(
              
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Confirm Password',
                hintText: 'Confirm password',
              ),
            ),
            ),
            
            //login button
            SizedBox(
              height: 65,
              width: 360,
              child:Container(
                child:Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.lightBlue,
                    ),
                    onPressed:() {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AppNav()));
                    },
                    child: Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 20)))
                
                )
              )
            ),
            
            SizedBox(
              height: 65,
              width: 360,
              child:Container(
                child:Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.grey[200],
                    ),
                    onPressed:() {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const loginPage()));
                    },
                    child: Text('Cancel', style: TextStyle(color: Colors.black, fontSize: 20)))
                
                )
              )
            )
            
          ]
        )
    ),
    );
  }
}

class loginPage extends StatelessWidget{
  const loginPage ({super.key});
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text ('Login Page')),
      body: SingleChildScrollView(
        child:Column(
          children: <Widget>[
            
            //spacer, include icon in this if wanted
            Padding(
              padding: const EdgeInsets.only(top:275.0),
            ),

            //username text field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:10.0),
              child:TextField(
                decoration:InputDecoration(
                  border:OutlineInputBorder(),
                  labelText: 'Email or Username',
                  hintText: "Enter valid email/username", 
                ),
              ),
            ),

            //password text field
            Padding(padding: const EdgeInsets.only(left: 10,right: 10, top: 10),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
                hintText: 'Enter valid password',
              ),
            ),
            ),
            
            //login button
            SizedBox(
              height: 65,
              width: 360,
              child:Container(
                child:Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.lightBlue,
                    ),
                    onPressed:() {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AppNav()));
                    },
                    child: Text('Log in', style: TextStyle(color: Colors.white, fontSize: 20)))
                
                )
              )
            ),
            
            //register button
            SizedBox(
              height: 65,
              width: 360,
              child:Container(
                child:Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.grey[200],
                    ),
                    onPressed:() {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const registerPage()));
                    },
                    child: Text('Register', style: TextStyle(color: Colors.black, fontSize: 20)))
                
                )
              )
            )
          ]
        )
    ),
    );
  }
}


class registerPage extends StatelessWidget{
  const registerPage ({super.key});
  @override
  Widget build(BuildContext context){
    return Scaffold (
      appBar: AppBar(title: const Text ('Register Page')),
      body: SingleChildScrollView(
        child:Column(
          children: <Widget>[
            
            //spacer, include icon in this if wanted
            Padding(
              padding: const EdgeInsets.only(top:175.0),
            ),

            //username text field
            Padding(
              padding: const EdgeInsets.only(left: 10,right: 10, top: 10),
              child:TextField(
                decoration:InputDecoration(
                  border:OutlineInputBorder(),
                  labelText: 'Enter Username',
                  hintText: "Enter valid username", 
                ),
              ),
            ),

            //email text field
            Padding(
              padding: const EdgeInsets.only(left: 10,right: 10, top: 10),
              child:TextField(
                decoration:InputDecoration(
                  border:OutlineInputBorder(),
                  labelText: 'Enter email',
                  hintText: "Enter valid email", 
                ),
              ),
            ),

            //phone text field
            Padding(
              padding: const EdgeInsets.only(left: 10,right: 10, top: 10),
              child:TextField(
                decoration:InputDecoration(
                  border:OutlineInputBorder(),
                  labelText: 'Enter phone number',
                  hintText: "Enter valid phone number", 
                ),
              ),
            ),



            //password text field
            Padding(padding: const EdgeInsets.only(left: 10,right: 10, top: 10),
            child: TextField(
              
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
                hintText: 'Enter valid password',
              ),
            ),
            ),
            // confirm password
            Padding(padding: const EdgeInsets.only(left: 10,right: 10, top: 10),
            child: TextField(
              
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Confirm Password',
                hintText: 'Confirm password',
              ),
            ),
            ),
            
            //login button
            SizedBox(
              height: 65,
              width: 360,
              child:Container(
                child:Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.lightBlue,
                    ),
                    onPressed:() {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AppNav()));
                    },
                    child: Text('Register', style: TextStyle(color: Colors.white, fontSize: 20)))
                
                )
              )
            ),
            
            SizedBox(
              height: 65,
              width: 360,
              child:Container(
                child:Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.grey[200],
                    ),
                    onPressed:() {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const loginPage()));
                    },
                    child: Text('Cancel', style: TextStyle(color: Colors.black, fontSize: 20)))
                
                )
              )
            )
            
          ]
        )
    ),
    );
  }

}

