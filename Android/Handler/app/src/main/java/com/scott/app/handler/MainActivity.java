package com.scott.app.handler;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import java.lang.ref.WeakReference;

public class MainActivity extends AppCompatActivity implements View.OnClickListener {
    private Button sendToWorkerButton;
    private TextView txtMessage;

    private static class UIHandler extends Handler {
        private final WeakReference<MainActivity> mActivity;

        UIHandler(MainActivity activity) {
            mActivity = new WeakReference<>(activity);
        }

        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            mActivity.get().txtMessage.setText("收到了来自线程" + msg.obj + "的消息!!!");
        }
    };

    private static Handler uiHandler;
    private WorkerThread workerThread;
    private final String TAG = "Handler";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        uiHandler = new UIHandler(this);
        workerThread = new WorkerThread();
        workerThread.start();

        sendToWorkerButton = (Button) findViewById(R.id.btn_send_worker);
        txtMessage = (TextView) findViewById(R.id.txt_message);
        sendToWorkerButton.setOnClickListener(this);

        // 测试子线程往主线程发送消息
        new Thread() {
            @Override
            public void run() {
                super.run();

                try {
                    Thread.currentThread().sleep(3000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }

                Message message = uiHandler.obtainMessage();
                message.obj = Thread.currentThread().getName();
                uiHandler.sendMessage(message);
            }
        }.start();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onClick(View v) {
        Message message = workerThread.workerHandler.obtainMessage();
        message.obj = Thread.currentThread().getName();
        workerThread.workerHandler.sendMessage(message);
    }

    class WorkerThread extends Thread {
        Handler workerHandler;

        @Override
        public void run() {
            super.run();

            Looper.prepare();
            workerHandler = new Handler() {
                @Override
                public void handleMessage(Message msg) {
                    super.handleMessage(msg);
                    Log.d(TAG,"收到了来自线程->" + msg.obj + "的消息!!!");
                }
            };
            Looper.loop();
        }
    }
}
