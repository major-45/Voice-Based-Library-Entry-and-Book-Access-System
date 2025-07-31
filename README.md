# Voice-Based-Library-Entry-and-Book-Access-System
This project is a voice-controlled automation system designed to streamline library access and book retrieval using a combination of speech recognition and pincode authentication, MATLAB GUI. The system enables students to enter a library and request books by simply speaking their ID and the book name.
System Workflow:
The system follows a multi-step voice-activated verification and access process:
1. Student Identification
- The student begins by speaking their unique ID.
- The system checks the spoken ID against a pre-existing database.
2. Verification
- If the ID is valid, the student must pass a password verification step.
- An incorrect ID or password results in access denial.
  
3. Book Request
- Upon successful login, the student speaks the name of the desired book.
- The system searches the library database to match the book name.
4. Book Retrieval
- Once the book is located:
  - Either the student or librarian manually collects it,
  - Or a robot is triggered to fetch the book automatically.
    
User Interfaces
Interphase 1 – Library Entry Management System
- Features:
  - Test, New Entry, Train buttons for speech model training/testing.
  - ID and password input for new or returning users.
  - Display area for system feedback.
- Purpose: Handles registration, login verification, and PIN management.
  
Interphase 2 – Library Book Finding System
- Features:
  - Button to speak and input the book name.
  - Display area to show matched book details.
- Purpose: Helps the student locate books via speech-based search.
  
Technologies Used
- MATLAB App Designer: GUI design for Interphase 1 & 2.
- Speech Recognition Toolbox: Converts spoken input to text.
- Database Handling: ID and book name verification.
- File I/O / Database: To manage user credentials and book inventory.
- 
Key Features
- ✅ Voice-based login and book search.
- ✅ GUI for intuitive user interaction.
- ✅ Password verification for two stage security.
- ✅ Library database lookup for book availability.
- ✅ Dual-mode book collection: Manual or Robotic.
  
How to Use
1. Launch the MATLAB application and open Interphase 1.
2. Register or enter ID and proceed with password input.
3. Once verified, system launches Interphase 2.
4. Speak the book name using the "Speak" button.
5. Collect the book manually or allow the robot to fetch it.
   
Security Considerations
ID and password verification provides basic access control.
Future work could include biometric voice authentication and role-based access (e.g., for staff and students).
Future Enhancements
- 🤖 Full integration with autonomous book-carrying robots.
- ☁️ Cloud-based database for distributed libraries.
- 📱 Mobile app interface using similar speech interface.
- 🔐 Improved encryption for password and speech data storage.
Project Structure (Example)
/voice_library_system/
├── entry_management.mlapp       # GUI: Interphase 1
├── book_finder.mlapp            # GUI: Interphase 2
├── id_database.mat              # Student ID and password data
├── books_database.mat           # Library book inventory
├── speech_recognition.m         # Handles voice input
├── robot_control.m              # Robot book collection logic (optional)
└── README.md                    # Project documentation

Contributors:
1. Wassie Haque
2. Md. Mohiuddin Ebrahim
3. Zubayer Ahmed Asif
4. Nurul Wara Rahat
5. Shuhab Uddin Julhas
   
   students of Batch 21,
   Department of Electrical and Electronic Engineering,
   Bangladesh University of Engineering and Technology,Dhaka, Bangladesh.

