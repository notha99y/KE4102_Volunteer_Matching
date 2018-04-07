using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Windows.Threading;

using CLIPSNET;

namespace VMatch
{
    public partial class MainWindow : Window
    {
        private class VWORecommendation
        {
            public string VwoName { get; set; }
            public int Certainty { get; set; }
            public string CertaintyText { get; set; }
            public string CertaintyWidthTaken { get; set; }
            public string CertaintyWidthLeft { get; set; }
        }

        String[] preferredFrequencyNames = { "No Preference", "AdHoc", "Weekly", "Monthly", "Annually" };
        String[] preferredOrgTypeNames = { "Don't Care", "Medical", "SocialSvc.Women", "SocialSvc.Children", "Animal", "Sports"};
        //String[] preferredAreaNames = { "No Preference", "North", "NorthEast", "East", "South", "West", "Central", "Overseas" };
        String[] preferredAreaNames = { "No Preference", "North", "NorthEast", "East", "South", "West", "Central" };
        String[] preferredDurationNames = { "No Preference", "Morning", "Afternoon", "Less than 8hrs", "Whole day" };

        String[] causesNames = { "No Preference", "Health", "Community", "Disability", "Elderly", "Children", "Youth", "Families", "Women", "Social Service", "Animals", "Education", "Humanitarian", "Environment", "Arts & Heritage", "Sports", "Other" };
        String[] dayNames = { "No Preference", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday", "Any Weekday", "Any Weekend" };
        String[] locationNames = { "No Preference", "Islandwide", "Ang Mo Kio", "Bedok", "Bishan", "Boon Lay", "Bukit Batok", "Bukit Merah", "Bukit Pangjang", "Bukit Timah", "Choa Chu Kang",
                                    "Downtown Core", "Geylang", "Hougang", "Jurong East", "Kallang", "Novena", "Orchard", "Outram", "Paya Lebar", "Pioneer", "Punggol", "Queenstown",
                                    "River Valley", "Rochor", "Sembawang", "Sengkang", "Serangoon", "Tampines", "Tanglin", "Toa Payoh", "Woodlands", "Yishun"  };

        //String[] agegroupNames = { "Private", "13-20", "21-35", "36-54", "55 onwards", "Other" };
        String[] agegroupNames = { "Private", "13-20", "21-35", "36-54", "55 onwards" };
        //String[] skillNames = { "None", "Medical & Health", "First Aid", "CPR", "IT", "Special Needs", "Early Childhood", "Medical", "Photography", "Coaching & Training", "Arts & Music", "Human Resource", "Volunteer Management", "Other" };
        String[] skillNames = { "None", "Medical & Health", "First Aid", "CPR", "Information Technology", "Special Needs", "Early Childhood", "Photography", "Coaching & Training", "Arts & Music", "Human Resource", "Volunteer Management", "Counselling & Mentoring", "Leadership & Development", "Legal", "Befriending", "Other" };
        String[] mygroupsizeNames = { "Don't Know", "Solo/No Group", "2-5", "6-10", "More than 10"};
        //String[] dayofweekNames = { "Don't Know", "Solo", "2-5", "6-10", "More than 10"};
        String[] a_valuesNames = { "Don't Know", "ABC", "XYZ" };
		
        String[] preferredFrequencyChoices;
        String[] preferredOrgTypeChoices;
        String[] preferredAreaChoices;
        String[] preferredDurationChoices;
		String[] myGroupSizeChoices;
		String[] preferredDOWChoices;

        String[] causesChoices;
        String[] dayChoices;
        String[] locationChoices;

        String[] agegroupChoices;
        String[] skillChoices;
        String[] a_valuesChoices;

        private CLIPSNET.Environment clips;
        private bool formLoaded = false;

        public MainWindow()
        {
            Dispatcher.BeginInvoke(DispatcherPriority.Loaded, new Action(() => { OnLoad(); }));
            InitializeComponent();
            clips = new CLIPSNET.Environment();
            clips.LoadFromResource("VMatch", "VMatch.volunteer.clp");
        }

        private String[] GenerateChoices(
          String[] names)
        {
            String[] choices = new String[names.Count()];

            for (int i = 0; i < names.Count(); i++)
            { choices[i] = names[i]; }

            return choices;
        }

        private void OnLoad()
        {
            RunVWO();
            formLoaded = true;
        }

        private void FrequencyComboBox_Loaded(object sender, RoutedEventArgs e)
        {
            preferredFrequencyChoices = GenerateChoices(preferredFrequencyNames);

            var frequencyComboBox = sender as ComboBox;

            frequencyComboBox.ItemsSource = preferredFrequencyChoices;

            frequencyComboBox.SelectedIndex = 0;
        }

        private void OrgTypeComboBox_Loaded(object sender, RoutedEventArgs e)
        {
            preferredOrgTypeChoices = GenerateChoices(preferredOrgTypeNames);

            var orgtypeComboBox = sender as ComboBox;

            orgtypeComboBox.ItemsSource = preferredOrgTypeChoices;

            orgtypeComboBox.SelectedIndex = 0;
        }

        private void AreaComboBox_Loaded(object sender, RoutedEventArgs e)
        {
            preferredAreaChoices = GenerateChoices(preferredAreaNames);

            var areaComboBox = sender as ComboBox;

            areaComboBox.ItemsSource = preferredAreaChoices;

            areaComboBox.SelectedIndex = 0;
        }

        private void DurationComboBox_Loaded(object sender, RoutedEventArgs e)
        {
            preferredDurationChoices = GenerateChoices(preferredDurationNames);

            var durationComboBox = sender as ComboBox;

            durationComboBox.ItemsSource = preferredDurationChoices;

            durationComboBox.SelectedIndex = 0;
        }

        private void CausesComboBox_Loaded(object sender, RoutedEventArgs e)
        {
            causesChoices = GenerateChoices(causesNames);

            var causesComboBox = sender as ComboBox;

            causesComboBox.ItemsSource = causesChoices;

            causesComboBox.SelectedIndex = 0;
        }

        private void DayComboBox_Loaded(object sender, RoutedEventArgs e)
        {
            dayChoices = GenerateChoices(dayNames);

            var dayComboBox = sender as ComboBox;

            dayComboBox.ItemsSource = dayChoices;

            dayComboBox.SelectedIndex = 0;
        }

        // Location selection and clips assert to location hard to work until we can assign a variable to "locationChoices" in CLIPS.

        private void LocationComboBox_Loaded(object sender, RoutedEventArgs e)
        {
            //locationChoices = GenerateChoices(locationNames);
            locationChoices = GenerateChoices(preferredAreaNames);

            var locationComboBox = sender as ComboBox;

            locationComboBox.ItemsSource = locationChoices;

            locationComboBox.SelectedIndex = 0;
        }

        private void AgeGroupComboBox_Loaded(object sender, RoutedEventArgs e)
        {
            agegroupChoices = GenerateChoices(agegroupNames);

            var agegroupComboBox = sender as ComboBox;

            agegroupComboBox.ItemsSource = agegroupChoices;

            agegroupComboBox.SelectedIndex = 0;
        }

        private void SkillComboBox_Loaded(object sender, RoutedEventArgs e)
        {
            skillChoices = GenerateChoices(skillNames);

            var skillComboBox = sender as ComboBox;

            skillComboBox.ItemsSource = skillChoices;

            skillComboBox.SelectedIndex = 0;
        }

        private void MyGroupSizeComboBox_Loaded(object sender, RoutedEventArgs e)
        {
            myGroupSizeChoices = GenerateChoices(mygroupsizeNames);

            var mygroupsizeComboBox = sender as ComboBox;

            mygroupsizeComboBox.ItemsSource = myGroupSizeChoices;

            mygroupsizeComboBox.SelectedIndex = 0;
        }

        // private void DayOfWeekComboBox_Loaded(object sender, RoutedEventArgs e)
        // {
            // myGroupSizeChoices = GenerateChoices(dayNames);

            // var mygroupsizeComboBox = sender as ComboBox;

            // mygroupsizeComboBox.ItemsSource = mygroupsizeChoices;

            // mygroupsizeComboBox.SelectedIndex = 0;
        // }

        private void a_ValuesComboBox_Loaded(object sender, RoutedEventArgs e)
        {
            a_valuesChoices = GenerateChoices(a_valuesNames);

            var a_valuesComboBox = sender as ComboBox;

            a_valuesComboBox.ItemsSource = a_valuesChoices;

            a_valuesComboBox.SelectedIndex = 0;
        }
		
        private void OnChange(object sender, SelectionChangedEventArgs e)
        {
            if (formLoaded)
            { RunVWO(); }
        }

        private void RunVWO()
        {
            clips.Reset();

            string item = (string)dayComboBox.SelectedValue;
			
            if (item.Equals("No Preference"))
            { clips.AssertString("(attribute (name preferred-dow) (value anyday))"); }
            else if (item.Equals("Monday"))
            { clips.AssertString("(attribute (name preferred-dow) (value monday))"); }
            else if (item.Equals("Tuesday"))
            { clips.AssertString("(attribute (name preferred-dow) (value tuesday))"); }
            else if (item.Equals("Wednesday"))
            { clips.AssertString("(attribute (name preferred-dow) (value wednesday))"); }
            else if (item.Equals("Thursday"))
            { clips.AssertString("(attribute (name preferred-dow) (value thursday))"); }
            else if (item.Equals("Friday"))
            { clips.AssertString("(attribute (name preferred-dow) (value friday))"); }
            else if (item.Equals("Saturday"))
            { clips.AssertString("(attribute (name preferred-dow) (value saturday))"); }
            else if (item.Equals("Sunday"))
            { clips.AssertString("(attribute (name preferred-dow) (value sunday))"); }
            else if (item.Equals("Any Weekday"))
            { clips.AssertString("(attribute (name preferred-dow) (value weekday))"); }
            else if (item.Equals("Any Weekend"))
            { clips.AssertString("(attribute (name preferred-dow) (value weekend))"); }
            else
            { clips.AssertString("(attribute (name preferred-dow) (value unknown))"); }
		
            //item = (string)orgtypeComboBox.SelectedValue;

            //if (item.Equals("Medical"))
            //{ clips.AssertString("(attribute (name preferred-orgtype) (value medical))"); }
            //else if (item.Equals("SocialSvc.Children"))
            //{ clips.AssertString("(attribute (name preferred-orgtype) (value ss.children))"); }
            //else if (item.Equals("SocialSvc.Women"))
            //{ clips.AssertString("(attribute (name preferred-orgtype) (value ss.women))"); }
            //else if (item.Equals("Animal"))
            //{ clips.AssertString("(attribute (name preferred-orgtype) (value animal))"); }
            //else if (item.Equals("Sports"))
            //{ clips.AssertString("(attribute (name preferred-orgtype) (value sports))"); }
            //else
            //{ clips.AssertString("(attribute (name preferred-orgtype) (value unknown))"); }

            //item = (string)areaComboBox.SelectedValue;

            //if (item.Equals("North"))
            //{ clips.AssertString("(attribute (name preferred-area) (value north))"); }
            //else if (item.Equals("NorthEast"))
            //{ clips.AssertString("(attribute (name preferred-area) (value northeast))"); }
            //else if (item.Equals("East"))
            //{ clips.AssertString("(attribute (name preferred-area) (value east))"); }
            //else if (item.Equals("South"))
            //{ clips.AssertString("(attribute (name preferred-area) (value south))"); }
            //else if (item.Equals("West"))
            //{ clips.AssertString("(attribute (name preferred-area) (value west))"); }
            //else
            //{ clips.AssertString("(attribute (name preferred-area) (value unknown))"); }

            item = (string)causesComboBox.SelectedValue;

            // if (item.Equals("Elderly") ||
                // item.Equals("Social Service"))
                // clips.AssertString("(attribute (name p-cause) (value socialservice))");
            if (item.Equals("Elderly"))
                clips.AssertString("(attribute (name p-cause) (value elderly))");
            else if (item.Equals("Health"))
                clips.AssertString("(attribute (name p-cause) (value health))");
            else if (item.Equals("Community"))
                clips.AssertString("(attribute (name p-cause) (value community))");
            else if (item.Equals("Disability"))
                clips.AssertString("(attribute (name p-cause) (value disability))");
            else if (item.Equals("Children") ||
                item.Equals("Youth"))
                clips.AssertString("(attribute (name p-cause) (value childrenyouth))");
            else if (item.Equals("Families"))
                clips.AssertString("(attribute (name p-cause) (value families))");
            else if (item.Equals("Women"))
                clips.AssertString("(attribute (name p-cause) (value womengirls))");
            else if (item.Equals("Social Service"))
                clips.AssertString("(attribute (name p-cause) (value socialservice))");
            else if (item.Equals("Animals"))
                clips.AssertString("(attribute (name p-cause) (value animals))");
            else if (item.Equals("Education"))
                clips.AssertString("(attribute (name p-cause) (value education))");
            else if (item.Equals("Humanitarian"))
                clips.AssertString("(attribute (name p-cause) (value humanitarian))");
            else if (item.Equals("Environment"))
                clips.AssertString("(attribute (name p-cause) (value environment))");
            else if (item.Equals("Arts & Heritage"))
                clips.AssertString("(attribute (name p-cause) (value artsheritage))");
            else if (item.Equals("Sports"))
                clips.AssertString("(attribute (name p-cause) (value sports))");
            else if (item.Equals("Other"))
                clips.AssertString("(attribute (name p-cause) (value unknown))");
            else
                clips.AssertString("(attribute (name p-cause) (value unknown))");

            // item = (string)dayComboBox.SelectedValue;

            // if (item.Equals("None"))
            // { clips.AssertString("(attribute (name has-sauce) (value no))"); }
            // else if (item.Equals("Spicy"))
            // {
                // clips.AssertString("(attribute (name has-sauce) (value yes))");
                // clips.AssertString("(attribute (name sauce) (value spicy))");
            // }
            // else if (item.Equals("Sweet"))
            // {
                // clips.AssertString("(attribute (name has-sauce) (value yes))");
                // clips.AssertString("(attribute (name sauce) (value sweet))");
            // }
            // else if (item.Equals("Cream"))
            // {
                // clips.AssertString("(attribute (name has-sauce) (value yes))");
                // clips.AssertString("(attribute (name sauce) (value cream))");
            // }
            // else if (item.Equals("Other"))
            // {
                // clips.AssertString("(attribute (name has-sauce) (value yes))");
                // clips.AssertString("(attribute (name sauce) (value unknown))");
            // }
            // else
            // {
                // clips.AssertString("(attribute (name has-sauce) (value unknown))");
                // clips.AssertString("(attribute (name sauce) (value unknown))");
            // }

            // Location selection and clips assert to location hard to work until we can assign a variable to "locationChoices" in CLIPS.

            item = (string)locationComboBox.SelectedValue;
            if (item.Equals("North"))
            { clips.AssertString("(attribute (name preferred-area) (value north))"); }
            else if (item.Equals("NorthEast"))
            { clips.AssertString("(attribute (name preferred-area) (value northeast))"); }
            else if (item.Equals("East"))
            { clips.AssertString("(attribute (name preferred-area) (value east))"); }
            else if (item.Equals("South"))
            { clips.AssertString("(attribute (name preferred-area) (value south))"); }
            else if (item.Equals("West"))
            { clips.AssertString("(attribute (name preferred-area) (value west))"); }
            else if (item.Equals("Central"))
            { clips.AssertString("(attribute (name preferred-area) (value central))"); }
            else if (item.Equals("Overseas"))
            { clips.AssertString("(attribute (name preferred-area) (value overseas))"); }
            else
            { clips.AssertString("(attribute (name preferred-area) (value unknown))"); }
            //if (item.Equals("No Preference"))
            //{ clips.AssertString("(attribute (name preferred-location) (value unknown))"); }
            //else
            //{ clips.AssertString("(attribute (name preferred-location) (value ))"); }

            item = (string)agegroupComboBox.SelectedValue;
            if (item.Equals("13-20"))
            { clips.AssertString("(attribute (name agegroup) (value teen))"); }
            else if (item.Equals("21-35"))
            { clips.AssertString("(attribute (name agegroup) (value youth))"); }
            else if (item.Equals("36-54"))
            { clips.AssertString("(attribute (name agegroup) (value middle))"); }
            else if (item.Equals("55 onwards"))
            { clips.AssertString("(attribute (name agegroup) (value 55plus))"); }
            else if (item.Equals("Other"))
            { clips.AssertString("(attribute (name agegroup) (value other))"); }
            else
            { clips.AssertString("(attribute (name agegroup) (value unknown))"); }

            item = (string)skillComboBox.SelectedValue;
            if (item.Equals("Medical & Health"))
            { clips.AssertString("(attribute (name skill) (value medicalhealth))"); }
            else if (item.Equals("First Aid"))
            { clips.AssertString("(attribute (name skill) (value firstaid))"); }
            else if (item.Equals("CPR"))
            { clips.AssertString("(attribute (name skill) (value cpr))"); }
            else if (item.Equals("Information Technology"))
            { clips.AssertString("(attribute (name skill) (value infotech))"); }
            else if (item.Equals("Special Needs"))
            { clips.AssertString("(attribute (name skill) (value specialneeds))"); }
            else if (item.Equals("Early Childhood"))
            { clips.AssertString("(attribute (name skill) (value earlychild))"); }
            //else if (item.Equals("Medical"))
            //{ clips.AssertString("(attribute (name skill) (value medical))"); }
            else if (item.Equals("Photography"))
            { clips.AssertString("(attribute (name skill) (value photography))"); }
            else if (item.Equals("Coaching & Training"))
            { clips.AssertString("(attribute (name skill) (value coachtrain))"); }
            else if (item.Equals("Arts & Music"))
            { clips.AssertString("(attribute (name skill) (value artsmusic))"); }
            else if (item.Equals("Human Resource"))
            { clips.AssertString("(attribute (name skill) (value humanresource))"); }
            else if (item.Equals("Volunteer Management"))
            { clips.AssertString("(attribute (name skill) (value volunteermgmt))"); }
            else if (item.Equals("Counselling & Mentoring"))
            { clips.AssertString("(attribute (name skill) (value counsellingmentoring))"); }
            else if (item.Equals("Leadership & Development"))
            { clips.AssertString("(attribute (name skill) (value leaddevt))"); }
            else if (item.Equals("Legal"))
            { clips.AssertString("(attribute (name skill) (value legal))"); }
            else if (item.Equals("Befriending"))
            { clips.AssertString("(attribute (name skill) (value befriend))"); }
            else if (item.Equals("Other"))
            { clips.AssertString("(attribute (name skill) (value other))"); }
            else
            { clips.AssertString("(attribute (name skill) (value unknown))"); }

            item = (string)mygroupsizeComboBox.SelectedValue;
            if (item.Equals("Solo"))
            { clips.AssertString("(attribute (name mygroupsize) (value solo))"); }
            else if (item.Equals("2-5"))
            { clips.AssertString("(attribute (name mygroupsize) (value 2-5))"); }
            else if (item.Equals("6-10"))
            { clips.AssertString("(attribute (name mygroupsize) (value 6-10))"); }
            else if (item.Equals("More than 10"))
            { clips.AssertString("(attribute (name mygroupsize) (value 11plus))"); }
            else
            { clips.AssertString("(attribute (name mygroupsize) (value unknown))"); }

            item = (string)durationComboBox.SelectedValue;

            if (item.Equals("Morning"))
            { clips.AssertString("(attribute (name preferred-duration) (value am))"); }
            else if (item.Equals("Afternoon"))
            { clips.AssertString("(attribute (name preferred-duration) (value pm))"); }
            else if (item.Equals("Less than 8hrs"))
            { clips.AssertString("(attribute (name preferred-duration) (value lessthan8))"); }
            else if (item.Equals("Whole day"))
            { clips.AssertString("(attribute (name preferred-duration) (value wholeday))"); }
            else
            { clips.AssertString("(attribute (name preferred-duration) (value flexible))"); }

            //string item = (string)frequencyComboBox.SelectedValue;
            item = (string)frequencyComboBox.SelectedValue;

            if (item.Equals("Adhoc"))
            { clips.AssertString("(attribute (name preferred-freq) (value adhoc))"); }
            else if (item.Equals("Annually"))
            { clips.AssertString("(attribute (name preferred-freq) (value annually))"); }
            else if (item.Equals("Weekly"))
            { clips.AssertString("(attribute (name preferred-freq) (value weekly))"); }
            else if (item.Equals("Monthly"))
            { clips.AssertString("(attribute (name preferred-freq) (value monthly))"); }
            else
            { clips.AssertString("(attribute (name preferred-freq) (value unknown))"); }

            //item = (string)a_valuesComboBox.SelectedValue;
            //if (item.Equals("ABC"))
            //{ clips.AssertString("(attribute (name a_values) (value abc))"); }
            //else if (item.Equals("XYZ"))
            //{ clips.AssertString("(attribute (name a_values) (value xyz))"); }
            //else
            //{ clips.AssertString("(attribute (name a_values) (value unknown))"); }

            clips.Run();

            UpdateVWOs();
        }

        private void UpdateVWOs()
        {
            string evalStr = "(VWOs::get-vwo-list)";
            List<VWORecommendation> vwoList = new List<VWORecommendation>();

            foreach (FactAddressValue fv in clips.Eval(evalStr) as MultifieldValue)
            {
                int certainty = (int)(((NumberValue)fv["certainty"]));

                String vwoName = ((LexemeValue)fv["value"]).Value;

                vwoList.Add(new VWORecommendation()
                {
                    VwoName = vwoName,
                    Certainty = certainty,
                    CertaintyText = certainty + "%",
                    CertaintyWidthTaken = certainty + "*",
                    CertaintyWidthLeft = (100 - certainty) + "*"
                });
            }

            resultsDataGridView.ItemsSource = vwoList;
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            frequencyComboBox.SelectedIndex = 0;
			//orgtypeComboBox.SelectedIndex = 0;
			//areaComboBox.SelectedIndex = 0;
			durationComboBox.SelectedIndex = 0;
			causesComboBox.SelectedIndex = 0;
			dayComboBox.SelectedIndex = 0;
			locationComboBox.SelectedIndex = 0;
			agegroupComboBox.SelectedIndex = 0;
			skillComboBox.SelectedIndex = 0;
			mygroupsizeComboBox.SelectedIndex = 0;
			//a_valuesComboBox.SelectedIndex = 0;
        }
    }
}
